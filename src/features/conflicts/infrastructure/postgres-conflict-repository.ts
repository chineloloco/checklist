import { and, asc, eq, inArray, sql } from "drizzle-orm";
import { getDb } from "@/infrastructure/db/client";
import {
  auditEvents,
  conflictCases,
  conflictMembers,
  inspectionRevisions,
  inspections,
  inspectionSlots,
  operationConfigs,
  responses,
  weeklyChecklists,
} from "@/infrastructure/db/schema";
import { conflict, notFound, validationFailed } from "@/shared/domain/errors";
import type { ResolveConflictInput } from "@/features/conflicts/domain/conflict";

type Context = { organizationId: string; userId: string };

export class PostgresConflictRepository {
  private get database() {
    return getDb();
  }

  async list(context: Context, status?: "OPEN" | "RESOLVED") {
    const conditions = [eq(conflictCases.organizationId, context.organizationId)];
    if (status) conditions.push(eq(conflictCases.status, status));
    const cases = await this.database
      .select()
      .from(conflictCases)
      .where(and(...conditions))
      .orderBy(asc(conflictCases.createdAt));
    return Promise.all(cases.map((item) => this.detail(context, item.id)));
  }

  async detail(context: Context, conflictId: string) {
    const [item] = await this.database
      .select()
      .from(conflictCases)
      .where(
        and(
          eq(conflictCases.id, conflictId),
          eq(conflictCases.organizationId, context.organizationId),
        ),
      )
      .limit(1);
    if (!item) throw notFound("Conflito não encontrado.");
    const members = await this.database
      .select({
        inspectionId: conflictMembers.inspectionId,
        role: conflictMembers.role,
        localDate: inspectionSlots.localDate,
        occurrenceNo: inspectionSlots.occurrenceNo,
        lifecycleStatus: inspections.lifecycleStatus,
        revision: inspections.currentRevision,
        deviceId: inspections.deviceId,
      })
      .from(conflictMembers)
      .innerJoin(inspections, eq(inspections.id, conflictMembers.inspectionId))
      .innerJoin(inspectionSlots, eq(inspectionSlots.id, inspections.slotId))
      .where(eq(conflictMembers.conflictId, conflictId));
    return { ...item, members };
  }

  async resolve(
    context: Context,
    conflictId: string,
    baseRevision: number,
    input: ResolveConflictInput,
  ) {
    await this.database.transaction(async (tx) => {
      await tx.execute(sql`select pg_advisory_xact_lock(hashtext(${`conflict:${conflictId}`}))`);
      const [item] = await tx
        .select()
        .from(conflictCases)
        .where(
          and(
            eq(conflictCases.id, conflictId),
            eq(conflictCases.organizationId, context.organizationId),
          ),
        )
        .limit(1);
      if (!item) throw notFound("Conflito não encontrado.");
      if (item.status !== "OPEN")
        throw conflict("CONFLICT_ALREADY_RESOLVED", "O conflito já foi resolvido.");
      if (item.revision !== baseRevision)
        throw conflict("REVISION_CONFLICT", "O conflito foi alterado.", {
          currentRevision: item.revision,
        });
      const members = await tx
        .select()
        .from(conflictMembers)
        .where(eq(conflictMembers.conflictId, conflictId));
      const memberIds = members.map((member) => member.inspectionId);
      const primaryId = input.primaryInspectionId;
      if (!primaryId || !memberIds.includes(primaryId))
        throw validationFailed("Selecione uma inspeção principal pertencente ao conflito.");

      if (input.resolution === "KEEP_SEPARATE") {
        const rows = await tx
          .select({
            inspection: inspections,
            slot: inspectionSlots,
            max: operationConfigs.maxOccurrencesPerDate,
          })
          .from(inspections)
          .innerJoin(inspectionSlots, eq(inspectionSlots.id, inspections.slotId))
          .innerJoin(weeklyChecklists, eq(weeklyChecklists.id, inspections.weeklyChecklistId))
          .innerJoin(operationConfigs, eq(operationConfigs.id, weeklyChecklists.operationConfigId))
          .where(inArray(inspections.id, memberIds));
        const candidate = rows.find((row) => row.inspection.id !== primaryId);
        if (!candidate || candidate.max < 2)
          throw validationFailed(
            "A configuração vigente não permite múltiplas inspeções na mesma data.",
          );
        const nextOccurrence = Math.max(...rows.map((row) => row.slot.occurrenceNo)) + 1;
        if (nextOccurrence > candidate.max)
          throw validationFailed("Não há ocorrência livre na data.");
        const [newSlot] = await tx
          .insert(inspectionSlots)
          .values({
            weeklyChecklistId: candidate.inspection.weeklyChecklistId,
            localDate: candidate.slot.localDate,
            occurrenceNo: nextOccurrence,
          })
          .returning();
        await tx
          .update(inspections)
          .set({ slotId: newSlot.id, isConflictCandidate: false, updatedAt: new Date() })
          .where(eq(inspections.id, candidate.inspection.id));
        await tx
          .update(inspections)
          .set({ isConflictCandidate: false, updatedAt: new Date() })
          .where(eq(inspections.id, primaryId));
      } else if (input.resolution === "MERGE") {
        const choices = input.itemChoices ?? [];
        if (!choices.length)
          throw validationFailed("Informe a origem escolhida para os itens divergentes.");
        const currentRows = await tx
          .select({ inspection: inspections, revision: inspectionRevisions })
          .from(inspections)
          .innerJoin(
            inspectionRevisions,
            and(
              eq(inspectionRevisions.inspectionId, inspections.id),
              eq(inspectionRevisions.revisionNumber, inspections.currentRevision),
            ),
          )
          .where(inArray(inspections.id, memberIds));
        const primary = currentRows.find((row) => row.inspection.id === primaryId);
        if (!primary) throw validationFailed("Inspeção principal inválida.");
        const answers = await tx
          .select()
          .from(responses)
          .where(
            inArray(
              responses.inspectionRevisionId,
              currentRows.map((row) => row.revision.id),
            ),
          );
        const revisionByInspection = new Map(
          currentRows.map((row) => [row.inspection.id, row.revision.id]),
        );
        const merged = new Map(
          answers
            .filter((answer) => answer.inspectionRevisionId === primary.revision.id)
            .map((answer) => [answer.templateItemId, answer]),
        );
        for (const choice of choices) {
          if (!memberIds.includes(choice.sourceInspectionId))
            throw validationFailed("Origem de resposta fora do conflito.");
          const sourceRevisionId = revisionByInspection.get(choice.sourceInspectionId);
          const answer = answers.find(
            (candidate) =>
              candidate.inspectionRevisionId === sourceRevisionId &&
              candidate.templateItemId === choice.itemId,
          );
          if (!answer) throw validationFailed("Resposta escolhida não encontrada.");
          merged.set(choice.itemId, answer);
        }
        const nextRevision = primary.inspection.currentRevision + 1;
        const [createdRevision] = await tx
          .insert(inspectionRevisions)
          .values({
            inspectionId: primaryId,
            revisionNumber: nextRevision,
            lifecycleStatus: "CORRECTED",
            identificationSnapshot: primary.revision.identificationSnapshot,
            observations: primary.revision.observations,
            correctionReason: input.reason,
            changes: choices,
            authoredBy: context.userId,
          })
          .returning();
        if (merged.size) {
          await tx.insert(responses).values(
            [...merged.values()].map((answer) => ({
              inspectionRevisionId: createdRevision.id,
              templateItemId: answer.templateItemId,
              result: answer.result,
              observation: answer.observation,
            })),
          );
        }
        await tx
          .update(inspections)
          .set({
            currentRevision: nextRevision,
            lifecycleStatus: "CORRECTED",
            isConflictCandidate: false,
            updatedAt: new Date(),
          })
          .where(eq(inspections.id, primaryId));
        for (const memberId of memberIds.filter((id) => id !== primaryId)) {
          await tx
            .update(inspections)
            .set({ isConflictCandidate: true, updatedAt: new Date() })
            .where(eq(inspections.id, memberId));
        }
      } else {
        for (const memberId of memberIds) {
          await tx
            .update(inspections)
            .set({ isConflictCandidate: memberId !== primaryId, updatedAt: new Date() })
            .where(eq(inspections.id, memberId));
        }
      }

      await tx
        .update(conflictCases)
        .set({
          status: "RESOLVED",
          resolution: input.resolution,
          reason: input.reason,
          resolvedBy: context.userId,
          resolvedAt: new Date(),
          revision: item.revision + 1,
          updatedAt: new Date(),
        })
        .where(eq(conflictCases.id, conflictId));
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "CONFLICT_CASE",
        entityId: conflictId,
        action: "RESOLVED",
        actorUserId: context.userId,
        reason: input.reason,
        metadata: { resolution: input.resolution, primaryInspectionId: primaryId },
      });
    });
    return this.detail(context, conflictId);
  }
}
