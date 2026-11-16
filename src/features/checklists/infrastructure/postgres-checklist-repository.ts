import { randomUUID } from "node:crypto";
import { and, asc, desc, eq, inArray, sql } from "drizzle-orm";
import { getDb } from "@/infrastructure/db/client";
import {
  assetTemplateAssignments,
  assets,
  auditEvents,
  checklistTemplates,
  conflictCases,
  conflictMembers,
  idempotencyReceipts,
  inspectionRevisions,
  inspections,
  inspectionSlots,
  operationConfigs,
  operationRequiredDays,
  responses,
  sites,
  companies,
  syncChangeLog,
  templateItems,
  templateSections,
  templateVersions,
  weeklyChecklists
} from "@/infrastructure/db/schema";
import { conflict, notFound, validationFailed } from "@/shared/domain/errors";
import { addDays, isDateInWeek, mondayOf } from "@/shared/domain/week";
import { hashPayload } from "@/shared/infrastructure/hash";
import type {
  CreateInspectionInput,
  InspectionResult,
  OpenWeeklyChecklistInput,
  UpdateInspectionInput
} from "@/features/checklists/domain/inspection";

type RequestContext = {
  organizationId: string;
  userId: string;
};

type StoredOperation = {
  statusCode: number;
  responseBody: Record<string, unknown>;
};

function resultFromBody(body: Record<string, unknown>): InspectionResult {
  return body as InspectionResult;
}

export class PostgresChecklistRepository {
  private get database() { return getDb(); }

  async openWeekly(context: RequestContext, input: OpenWeeklyChecklistInput) {
    return this.database.transaction(async (tx) => {
      const [configuration] = await tx
        .select({
          assetId: assets.id,
          templateId: checklistTemplates.id,
          versionId: templateVersions.id,
          operationConfigId: operationConfigs.id,
          timezone: operationConfigs.timezone
        })
        .from(assets)
        .innerJoin(
          assetTemplateAssignments,
          and(eq(assetTemplateAssignments.assetId, assets.id), eq(assetTemplateAssignments.active, true))
        )
        .innerJoin(
          checklistTemplates,
          and(
            eq(checklistTemplates.id, assetTemplateAssignments.templateId),
            eq(checklistTemplates.organizationId, context.organizationId),
            eq(checklistTemplates.status, "ACTIVE")
          )
        )
        .innerJoin(
          templateVersions,
          and(eq(templateVersions.templateId, checklistTemplates.id), eq(templateVersions.status, "PUBLISHED"))
        )
        .innerJoin(
          operationConfigs,
          and(eq(operationConfigs.id, assetTemplateAssignments.operationConfigId), eq(operationConfigs.active, true))
        )
        .where(
          and(
            eq(assets.id, input.assetId),
            eq(assets.organizationId, context.organizationId),
            eq(checklistTemplates.id, input.templateId),
            eq(assets.active, true)
          )
        )
        .orderBy(desc(templateVersions.versionNumber))
        .limit(1);

      if (!configuration) {
        throw notFound("Ativo, modelo publicado ou configuração aplicável não encontrado.");
      }

      const weekStartDate = mondayOf(input.localDate);
      const checklistId = input.clientWeeklyChecklistId ?? randomUUID();
      await tx.execute(
        sql`select pg_advisory_xact_lock(hashtext(${`weekly:${context.organizationId}:${input.assetId}:${input.templateId}:${weekStartDate}`}))`
      );

      const [existing] = await tx
        .select()
        .from(weeklyChecklists)
        .where(
          and(
            eq(weeklyChecklists.organizationId, context.organizationId),
            eq(weeklyChecklists.assetId, input.assetId),
            eq(weeklyChecklists.templateId, input.templateId),
            eq(weeklyChecklists.weekStartDate, weekStartDate)
          )
        )
        .limit(1);
      if (existing) return existing;

      const [created] = await tx
        .insert(weeklyChecklists)
        .values({
          id: checklistId,
          organizationId: context.organizationId,
          assetId: configuration.assetId,
          templateId: configuration.templateId,
          templateVersionId: configuration.versionId,
          operationConfigId: configuration.operationConfigId,
          weekStartDate,
          timezone: configuration.timezone,
          createdBy: context.userId
        })
        .returning();

      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "WEEKLY_CHECKLIST",
        entityId: created.id,
        action: "CREATED",
        actorUserId: context.userId,
        metadata: { templateVersionId: created.templateVersionId, weekStartDate }
      });
      await tx.insert(syncChangeLog).values({
        organizationId: context.organizationId,
        entityType: "WEEKLY_CHECKLIST",
        entityId: created.id,
        revision: created.revision,
        changeType: "UPSERT",
        payload: created
      });
      return created;
    });
  }

  async createInspection(
    context: RequestContext,
    weeklyChecklistId: string,
    operationId: string,
    input: CreateInspectionInput
  ): Promise<{ statusCode: number; result: InspectionResult; replayed: boolean }> {
    const requestHash = hashPayload({ weeklyChecklistId, input });
    return this.database.transaction(async (tx) => {
      await tx.execute(sql`select pg_advisory_xact_lock(hashtext(${`operation:${context.organizationId}:${input.deviceId}:${operationId}`}))`);
      const [receipt] = await tx
        .select()
        .from(idempotencyReceipts)
        .where(
          and(
            eq(idempotencyReceipts.organizationId, context.organizationId),
            eq(idempotencyReceipts.deviceId, input.deviceId),
            eq(idempotencyReceipts.operationId, operationId)
          )
        )
        .limit(1);
      if (receipt) {
        if (receipt.requestHash !== requestHash) {
          throw conflict("IDEMPOTENCY_KEY_REUSED", "A chave de idempotência já foi usada com outro conteúdo.");
        }
        return { statusCode: receipt.statusCode, result: resultFromBody(receipt.responseBody), replayed: true };
      }

      const [weekly] = await tx
        .select({
          id: weeklyChecklists.id,
          weekStartDate: weeklyChecklists.weekStartDate,
          templateVersionId: weeklyChecklists.templateVersionId,
          operationConfigId: weeklyChecklists.operationConfigId,
          maxOccurrences: operationConfigs.maxOccurrencesPerDate
        })
        .from(weeklyChecklists)
        .innerJoin(operationConfigs, eq(operationConfigs.id, weeklyChecklists.operationConfigId))
        .where(and(eq(weeklyChecklists.id, weeklyChecklistId), eq(weeklyChecklists.organizationId, context.organizationId)))
        .limit(1);
      if (!weekly) throw notFound("Checklist semanal não encontrado.");
      if (!isDateInWeek(input.localDate, weekly.weekStartDate)) {
        throw validationFailed("A data da inspeção não pertence à semana fixada.");
      }
      if (input.occurrenceNo > weekly.maxOccurrences) {
        throw validationFailed("A ocorrência excede a configuração vigente para a data.");
      }

      const allowedItems = await tx
        .select({
          id: templateItems.id,
          required: templateItems.requiredOnComplete,
          requireObservationWhenNc: templateItems.requireObservationWhenNc
        })
        .from(templateItems)
        .where(eq(templateItems.versionId, weekly.templateVersionId));
      this.validateResponses(input.lifecycleStatus, input.responses, allowedItems);

      const [slot] = await tx
        .insert(inspectionSlots)
        .values({
          weeklyChecklistId,
          localDate: input.localDate,
          occurrenceNo: input.occurrenceNo,
          expected: false
        })
        .onConflictDoUpdate({
          target: [inspectionSlots.weeklyChecklistId, inspectionSlots.localDate, inspectionSlots.occurrenceNo],
          set: { localDate: input.localDate }
        })
        .returning();

      await tx.execute(sql`select pg_advisory_xact_lock(hashtext(${`slot:${slot.id}`}))`);

      const [sameClient] = await tx
        .select({
          id: inspections.id,
          weeklyChecklistId: inspections.weeklyChecklistId,
          clientInspectionId: inspections.clientInspectionId,
          lifecycleStatus: inspections.lifecycleStatus,
          revision: inspections.currentRevision,
          creationHash: inspections.creationHash,
          localDate: inspectionSlots.localDate,
          occurrenceNo: inspectionSlots.occurrenceNo
        })
        .from(inspections)
        .innerJoin(inspectionSlots, eq(inspectionSlots.id, inspections.slotId))
        .where(
          and(
            eq(inspections.organizationId, context.organizationId),
            eq(inspections.clientInspectionId, input.clientInspectionId)
          )
        )
        .limit(1);
      if (sameClient) {
        if (sameClient.creationHash !== requestHash) {
          throw conflict("CLIENT_INSPECTION_ID_REUSED", "O identificador da inspeção já existe com outro conteúdo.");
        }
        const result: InspectionResult = {
          id: sameClient.id,
          weeklyChecklistId: sameClient.weeklyChecklistId,
          clientInspectionId: sameClient.clientInspectionId,
          localDate: sameClient.localDate,
          occurrenceNo: sameClient.occurrenceNo,
          lifecycleStatus: sameClient.lifecycleStatus,
          revision: sameClient.revision
        };
        await this.saveReceipt(tx, context.organizationId, input.deviceId, operationId, requestHash, 200, result);
        return { statusCode: 200, result, replayed: true };
      }

      const [existing] = await tx
        .select({ id: inspections.id })
        .from(inspections)
        .where(and(eq(inspections.slotId, slot.id), eq(inspections.isConflictCandidate, false)))
        .limit(1);

      const isConflict = Boolean(existing);
      const [created] = await tx
        .insert(inspections)
        .values({
          id: input.clientInspectionId,
          organizationId: context.organizationId,
          weeklyChecklistId,
          slotId: slot.id,
          clientInspectionId: input.clientInspectionId,
          deviceId: input.deviceId,
          creationHash: requestHash,
          lifecycleStatus: input.lifecycleStatus,
          currentRevision: 1,
          isConflictCandidate: isConflict,
          responsiblePersonId: input.identification.responsiblePersonId,
          createdBy: context.userId,
          completedAt: input.lifecycleStatus === "COMPLETED" ? new Date() : null
        })
        .returning();

      const [revision] = await tx
        .insert(inspectionRevisions)
        .values({
          inspectionId: created.id,
          revisionNumber: 1,
          lifecycleStatus: input.lifecycleStatus,
          identificationSnapshot: input.identification,
          observations: input.observations,
          changes: input.attachments,
          authoredBy: context.userId
        })
        .returning();
      if (input.responses.length) {
        await tx.insert(responses).values(
          input.responses.map((response) => ({
            inspectionRevisionId: revision.id,
            templateItemId: response.itemId,
            result: response.result,
            observation: response.observation
          }))
        );
      }

      let conflictId: string | undefined;
      if (existing) {
        const [conflictCase] = await tx
          .insert(conflictCases)
          .values({ organizationId: context.organizationId, type: "DUPLICATE_SLOT" })
          .returning();
        conflictId = conflictCase.id;
        await tx.insert(conflictMembers).values([
          { conflictId, inspectionId: existing.id, role: "EXISTING" },
          { conflictId, inspectionId: created.id, role: "CANDIDATE" }
        ]);
      }

      const result: InspectionResult = {
        id: created.id,
        weeklyChecklistId,
        clientInspectionId: created.clientInspectionId,
        localDate: input.localDate,
        occurrenceNo: input.occurrenceNo,
        lifecycleStatus: created.lifecycleStatus,
        revision: created.currentRevision,
        conflict: isConflict,
        conflictId
      };
      const statusCode = isConflict ? 409 : 201;

      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "INSPECTION",
        entityId: created.id,
        action: isConflict ? "CREATED_AS_CONFLICT_CANDIDATE" : "CREATED",
        actorUserId: context.userId,
        metadata: { localDate: input.localDate, occurrenceNo: input.occurrenceNo, conflictId }
      });
      await tx.insert(syncChangeLog).values({
        organizationId: context.organizationId,
        entityType: "INSPECTION",
        entityId: created.id,
        revision: 1,
        changeType: "UPSERT",
        payload: result
      });
      await this.saveReceipt(tx, context.organizationId, input.deviceId, operationId, requestHash, statusCode, result);
      return { statusCode, result, replayed: false };
    });
  }

  async updateInspection(
    context: RequestContext,
    inspectionId: string,
    input: UpdateInspectionInput
  ): Promise<InspectionResult> {
    const requestHash = hashPayload({ inspectionId, input });
    return this.database.transaction(async (tx) => {
      if (input.operationId && input.deviceId) {
        await tx.execute(
          sql`select pg_advisory_xact_lock(hashtext(${`operation:${context.organizationId}:${input.deviceId}:${input.operationId}`}))`
        );
        const [receipt] = await tx
          .select()
          .from(idempotencyReceipts)
          .where(
            and(
              eq(idempotencyReceipts.organizationId, context.organizationId),
              eq(idempotencyReceipts.deviceId, input.deviceId),
              eq(idempotencyReceipts.operationId, input.operationId)
            )
          )
          .limit(1);
        if (receipt) {
          if (receipt.requestHash !== requestHash) {
            throw conflict(
              "IDEMPOTENCY_KEY_REUSED",
              "A chave de idempotência já foi usada com outro conteúdo."
            );
          }
          return resultFromBody(receipt.responseBody);
        }
      }
      await tx.execute(sql`select pg_advisory_xact_lock(hashtext(${`inspection:${inspectionId}`}))`);
      const [current] = await tx
        .select({
          inspection: inspections,
          localDate: inspectionSlots.localDate,
          occurrenceNo: inspectionSlots.occurrenceNo,
          versionId: weeklyChecklists.templateVersionId
        })
        .from(inspections)
        .innerJoin(inspectionSlots, eq(inspectionSlots.id, inspections.slotId))
        .innerJoin(weeklyChecklists, eq(weeklyChecklists.id, inspections.weeklyChecklistId))
        .where(and(eq(inspections.id, inspectionId), eq(inspections.organizationId, context.organizationId)))
        .limit(1);
      if (!current) throw notFound("Inspeção não encontrada.");
      if (current.inspection.currentRevision !== input.baseRevision) {
        throw conflict("REVISION_CONFLICT", "A inspeção foi alterada em outro lugar.", {
          currentRevision: current.inspection.currentRevision
        });
      }
      if (current.inspection.lifecycleStatus !== "DRAFT" && !input.correctionReason) {
        throw conflict("INSPECTION_IMMUTABLE", "Uma inspeção concluída só pode ser alterada por correção auditada.");
      }

      const allowedItems = await tx
        .select({
          id: templateItems.id,
          required: templateItems.requiredOnComplete,
          requireObservationWhenNc: templateItems.requireObservationWhenNc
        })
        .from(templateItems)
        .where(eq(templateItems.versionId, current.versionId));
      const nextStatus = input.correctionReason ? "CORRECTED" : (input.lifecycleStatus ?? current.inspection.lifecycleStatus);
      this.validateResponses(nextStatus, input.responses, allowedItems);
      const nextRevision = current.inspection.currentRevision + 1;

      const [revision] = await tx
        .insert(inspectionRevisions)
        .values({
          inspectionId,
          revisionNumber: nextRevision,
          lifecycleStatus: nextStatus,
          identificationSnapshot: input.identification,
          observations: input.observations,
          correctionReason: input.correctionReason,
          changes: input.attachments,
          authoredBy: context.userId
        })
        .returning();
      if (input.responses.length) {
        await tx.insert(responses).values(
          input.responses.map((response) => ({
            inspectionRevisionId: revision.id,
            templateItemId: response.itemId,
            result: response.result,
            observation: response.observation
          }))
        );
      }
      const [updated] = await tx
        .update(inspections)
        .set({
          currentRevision: nextRevision,
          lifecycleStatus: nextStatus,
          completedAt: nextStatus === "COMPLETED" || nextStatus === "CORRECTED" ? new Date() : current.inspection.completedAt,
          updatedAt: new Date()
        })
        .where(eq(inspections.id, inspectionId))
        .returning();

      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "INSPECTION",
        entityId: inspectionId,
        action: input.correctionReason ? "CORRECTED" : nextStatus === "COMPLETED" ? "COMPLETED" : "DRAFT_SAVED",
        actorUserId: context.userId,
        reason: input.correctionReason,
        metadata: { previousRevision: input.baseRevision, revision: nextRevision }
      });
      const result: InspectionResult = {
        id: updated.id,
        weeklyChecklistId: updated.weeklyChecklistId,
        clientInspectionId: updated.clientInspectionId,
        localDate: current.localDate,
        occurrenceNo: current.occurrenceNo,
        lifecycleStatus: updated.lifecycleStatus,
        revision: updated.currentRevision
      };
      await tx.insert(syncChangeLog).values({
        organizationId: context.organizationId,
        entityType: "INSPECTION",
        entityId: updated.id,
        revision: updated.currentRevision,
        changeType: "UPSERT",
        payload: result
      });
      if (input.operationId && input.deviceId) {
        await this.saveReceipt(
          tx,
          context.organizationId,
          input.deviceId,
          input.operationId,
          requestHash,
          200,
          result
        );
      }
      return result;
    });
  }

  async getInspection(context: RequestContext, inspectionId: string) {
    const [current] = await this.database
      .select({
        inspection: inspections,
        localDate: inspectionSlots.localDate,
        occurrenceNo: inspectionSlots.occurrenceNo,
        revisionId: inspectionRevisions.id,
        identification: inspectionRevisions.identificationSnapshot,
        observations: inspectionRevisions.observations,
        attachments: inspectionRevisions.changes,
        correctionReason: inspectionRevisions.correctionReason,
        authoredAt: inspectionRevisions.authoredAt
      })
      .from(inspections)
      .innerJoin(inspectionSlots, eq(inspectionSlots.id, inspections.slotId))
      .innerJoin(
        inspectionRevisions,
        and(
          eq(inspectionRevisions.inspectionId, inspections.id),
          eq(inspectionRevisions.revisionNumber, inspections.currentRevision)
        )
      )
      .where(and(eq(inspections.id, inspectionId), eq(inspections.organizationId, context.organizationId)))
      .limit(1);
    if (!current) throw notFound("Inspeção não encontrada.");
    const answerRows = await this.database
      .select({ itemId: responses.templateItemId, result: responses.result, observation: responses.observation })
      .from(responses)
      .where(eq(responses.inspectionRevisionId, current.revisionId));
    const history = await this.database
      .select({
        revision: inspectionRevisions.revisionNumber,
        status: inspectionRevisions.lifecycleStatus,
        reason: inspectionRevisions.correctionReason,
        authoredAt: inspectionRevisions.authoredAt
      })
      .from(inspectionRevisions)
      .where(eq(inspectionRevisions.inspectionId, inspectionId))
      .orderBy(desc(inspectionRevisions.revisionNumber));
    return {
      id: current.inspection.id,
      weeklyChecklistId: current.inspection.weeklyChecklistId,
      clientInspectionId: current.inspection.clientInspectionId,
      localDate: current.localDate,
      occurrenceNo: current.occurrenceNo,
      lifecycleStatus: current.inspection.lifecycleStatus,
      revision: current.inspection.currentRevision,
      identification: current.identification,
      observations: current.observations,
      attachments: current.attachments,
      correctionReason: current.correctionReason,
      responses: answerRows,
      history
    };
  }

  async weeklyView(context: RequestContext, weeklyChecklistId: string) {
    const [weekly] = await this.database
      .select({
        id: weeklyChecklists.id,
        weekStartDate: weeklyChecklists.weekStartDate,
        timezone: weeklyChecklists.timezone,
        versionId: weeklyChecklists.templateVersionId,
        operationConfigId: weeklyChecklists.operationConfigId,
        assetCode: assets.code,
        templateName: checklistTemplates.name,
        siteName: sites.name,
        companyName: companies.name
      })
      .from(weeklyChecklists)
      .innerJoin(assets, eq(assets.id, weeklyChecklists.assetId))
      .innerJoin(checklistTemplates, eq(checklistTemplates.id, weeklyChecklists.templateId))
      .leftJoin(sites, eq(sites.id, assets.siteId))
      .innerJoin(companies, eq(companies.id, assets.companyId))
      .where(and(eq(weeklyChecklists.id, weeklyChecklistId), eq(weeklyChecklists.organizationId, context.organizationId)))
      .limit(1);
    if (!weekly) throw notFound("Checklist semanal não encontrado.");

    const sectionRows = await this.database
      .select({ id: templateSections.id, title: templateSections.title, order: templateSections.sortOrder })
      .from(templateSections)
      .where(eq(templateSections.versionId, weekly.versionId))
      .orderBy(asc(templateSections.sortOrder));
    const itemRows = await this.database
      .select({
        id: templateItems.id,
        sectionId: templateItems.sectionId,
        sourcePrintedNumber: templateItems.sourcePrintedNumber,
        text: templateItems.originalText,
        order: templateItems.sortOrder
      })
      .from(templateItems)
      .where(eq(templateItems.versionId, weekly.versionId))
      .orderBy(asc(templateItems.sortOrder));
    const inspectionRows = await this.database
      .select({
        id: inspections.id,
        localDate: inspectionSlots.localDate,
        occurrenceNo: inspectionSlots.occurrenceNo,
        lifecycleStatus: inspections.lifecycleStatus,
        revision: inspections.currentRevision,
        conflict: inspections.isConflictCandidate,
        revisionId: inspectionRevisions.id
      })
      .from(inspections)
      .innerJoin(inspectionSlots, eq(inspectionSlots.id, inspections.slotId))
      .innerJoin(
        inspectionRevisions,
        and(
          eq(inspectionRevisions.inspectionId, inspections.id),
          eq(inspectionRevisions.revisionNumber, inspections.currentRevision)
        )
      )
      .where(eq(inspections.weeklyChecklistId, weeklyChecklistId))
      .orderBy(asc(inspectionSlots.localDate), asc(inspectionSlots.occurrenceNo));
    const revisionIds = inspectionRows.map((row) => row.revisionId);
    const answerRows = revisionIds.length
      ? await this.database
          .select({
            revisionId: responses.inspectionRevisionId,
            itemId: responses.templateItemId,
            result: responses.result,
            observation: responses.observation
          })
          .from(responses)
          .where(inArray(responses.inspectionRevisionId, revisionIds))
      : [];
    const revisionToInspection = new Map(inspectionRows.map((row) => [row.revisionId, row.id]));
    const cellsByItem = new Map<
      string,
      Array<{ inspectionId: string; result: "C" | "NC" | "NA" | null; observation: string | null }>
    >();
    for (const answer of answerRows) {
      const inspectionId = revisionToInspection.get(answer.revisionId);
      if (!inspectionId) continue;
      const cells = cellsByItem.get(answer.itemId) ?? [];
      cells.push({
        inspectionId,
        result: answer.result,
        observation: answer.observation
      });
      cellsByItem.set(answer.itemId, cells);
    }

    const requiredDays = await this.database
      .select()
      .from(operationRequiredDays)
      .where(eq(operationRequiredDays.operationConfigId, weekly.operationConfigId));
    const requiredSlots = requiredDays.flatMap((rule) => {
      const localDate = addDays(weekly.weekStartDate, rule.weekday - 1);
      return Array.from({ length: rule.minimumOccurrences }, (_, index) => ({
        localDate,
        occurrenceNo: index + 1,
        fulfilled: inspectionRows.some(
          (inspection) =>
            inspection.localDate === localDate &&
            inspection.occurrenceNo === index + 1 &&
            inspection.lifecycleStatus !== "VOIDED" &&
            !inspection.conflict
        ),
        uncertainty: "A ausência no servidor pode representar uma inspeção ainda offline."
      }));
    });

    return {
      weeklyChecklistId: weekly.id,
      weekStartDate: weekly.weekStartDate,
      timezone: weekly.timezone,
      asset: { code: weekly.assetCode, templateName: weekly.templateName, site: weekly.siteName, company: weekly.companyName },
      columns: inspectionRows.map((row) => ({
        id: row.id,
        localDate: row.localDate,
        occurrenceNo: row.occurrenceNo,
        lifecycleStatus: row.lifecycleStatus,
        revision: row.revision,
        conflict: row.conflict,
        required: requiredSlots.some(
          (slot) => slot.localDate === row.localDate && slot.occurrenceNo === row.occurrenceNo
        )
      })),
      sections: sectionRows.map((section) => ({
        sectionId: section.id,
        title: section.title,
        items: itemRows
          .filter((item) => item.sectionId === section.id)
          .map((item) => ({
            itemId: item.id,
            sourcePrintedNumber: item.sourcePrintedNumber,
            text: item.text,
            cells: cellsByItem.get(item.id) ?? []
          }))
      })),
      requiredSlots
    };
  }

  async listWeekly(context: RequestContext, filters: { weekStartDate?: string; assetId?: string; templateId?: string }) {
    const conditions = [eq(weeklyChecklists.organizationId, context.organizationId)];
    if (filters.weekStartDate) conditions.push(eq(weeklyChecklists.weekStartDate, filters.weekStartDate));
    if (filters.assetId) conditions.push(eq(weeklyChecklists.assetId, filters.assetId));
    if (filters.templateId) conditions.push(eq(weeklyChecklists.templateId, filters.templateId));
    return this.database
      .select({
        id: weeklyChecklists.id,
        weekStartDate: weeklyChecklists.weekStartDate,
        timezone: weeklyChecklists.timezone,
        versionId: weeklyChecklists.templateVersionId,
        revision: weeklyChecklists.revision,
        assetId: assets.id,
        assetCode: assets.code,
        templateId: checklistTemplates.id,
        templateName: checklistTemplates.name,
        siteName: sites.name
      })
      .from(weeklyChecklists)
      .innerJoin(assets, eq(assets.id, weeklyChecklists.assetId))
      .innerJoin(checklistTemplates, eq(checklistTemplates.id, weeklyChecklists.templateId))
      .leftJoin(sites, eq(sites.id, assets.siteId))
      .where(and(...conditions))
      .orderBy(desc(weeklyChecklists.weekStartDate), asc(assets.code));
  }

  private validateResponses(
    lifecycleStatus: string,
    submitted: Array<{ itemId: string; result: "C" | "NC" | "NA" | null; observation?: string | null }>,
    allowedItems: Array<{ id: string; required: boolean; requireObservationWhenNc: boolean }>
  ) {
    const allowed = new Map(allowedItems.map((item) => [item.id, item]));
    const seen = new Set<string>();
    for (const response of submitted) {
      const item = allowed.get(response.itemId);
      if (!item) throw validationFailed("Uma resposta aponta para item de outra versão do modelo.");
      if (seen.has(response.itemId)) throw validationFailed("O mesmo item foi enviado mais de uma vez.");
      seen.add(response.itemId);
      if (response.result === "NC" && item.requireObservationWhenNc && !response.observation?.trim()) {
        throw validationFailed("O item NC exige observação conforme a versão publicada.");
      }
    }
    if (lifecycleStatus === "COMPLETED" || lifecycleStatus === "CORRECTED") {
      const missing = allowedItems.filter((item) => item.required && !submitted.some((answer) => answer.itemId === item.id && answer.result));
      if (missing.length) {
        throw validationFailed("Todos os itens obrigatórios devem ter C, NC ou NA antes da conclusão.", [
          ...missing.slice(0, 20).map((item) => ({ pointer: `/responses/${item.id}`, code: "REQUIRED", message: "Resposta obrigatória." }))
        ]);
      }
    }
  }

  private async saveReceipt(
    tx: Parameters<Parameters<typeof this.database.transaction>[0]>[0],
    organizationId: string,
    deviceId: string,
    operationId: string,
    requestHash: string,
    statusCode: number,
    responseBody: Record<string, unknown>
  ): Promise<StoredOperation> {
    await tx.insert(idempotencyReceipts).values({
      organizationId,
      deviceId,
      operationId,
      requestHash,
      statusCode,
      responseBody
    });
    return { statusCode, responseBody };
  }
}
