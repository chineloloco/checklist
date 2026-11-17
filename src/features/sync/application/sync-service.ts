import { and, asc, desc, eq, ne } from "drizzle-orm";
import type { AuthContext } from "@/features/auth/application/auth-context";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import {
  createInspectionSchema,
  openWeeklyChecklistSchema,
  updateInspectionSchema,
} from "@/features/checklists/domain/inspection";
import { ZodError, z } from "zod";
import type { syncPushSchema } from "@/features/sync/domain/sync";
import { getDb } from "@/infrastructure/db/client";
import {
  assets,
  auditEvents,
  assetTemplateAssignments,
  checklistTemplates,
  operationConfigs,
  operationRequiredDays,
  companies,
  people,
  sites,
  syncChangeLog,
  templateVersions,
} from "@/infrastructure/db/schema";
import { TemplateService } from "@/features/templates/application/template-service";
import { PostgresRegistryRepository } from "@/features/registry/infrastructure/postgres-registry-repository";
import { hasPermission } from "@/features/auth/domain/permissions";
import { DomainError } from "@/shared/domain/errors";
import { hashPayload } from "@/shared/infrastructure/hash";

type PushInput = z.infer<typeof syncPushSchema>;

export class SyncService {
  private get database() {
    return getDb();
  }
  private readonly checklists = new ChecklistService();
  private readonly templates = new TemplateService();

  async bootstrap(context: AuthContext, sinceCursor?: number) {
    if (sinceCursor) return this.pull(context, sinceCursor, 500);
    const versions = await this.database
      .select({ id: templateVersions.id })
      .from(templateVersions)
      .innerJoin(checklistTemplates, eq(checklistTemplates.id, templateVersions.templateId))
      .where(
        and(
          eq(templateVersions.status, "PUBLISHED"),
          eq(templateVersions.organizationId, context.organizationId),
          eq(checklistTemplates.status, "ACTIVE"),
        ),
      );
    const templateVersionsData = [];
    for (const version of versions)
      templateVersionsData.push(await this.templates.version(context, version.id));
    const assetRows = await this.database
      .select()
      .from(assets)
      .where(and(eq(assets.organizationId, context.organizationId), eq(assets.active, true)));
    const configRows = await this.database
      .select()
      .from(operationConfigs)
      .where(
        and(
          eq(operationConfigs.organizationId, context.organizationId),
          eq(operationConfigs.active, true),
        ),
      );
    const requiredDays = await this.database.select().from(operationRequiredDays);
    const weekdayNames = [
      "",
      "MONDAY",
      "TUESDAY",
      "WEDNESDAY",
      "THURSDAY",
      "FRIDAY",
      "SATURDAY",
      "SUNDAY",
    ];
    const configs = configRows.map((config) => ({
      ...config,
      requiredWeekdays: requiredDays
        .filter((day) => day.operationConfigId === config.id)
        .map((day) => weekdayNames[day.weekday]),
    }));
    const assignments = await this.database
      .select()
      .from(assetTemplateAssignments)
      .where(
        and(
          eq(assetTemplateAssignments.organizationId, context.organizationId),
          eq(assetTemplateAssignments.active, true),
        ),
      );
    const companyRows = await this.database
      .select()
      .from(companies)
      .where(and(eq(companies.organizationId, context.organizationId), eq(companies.active, true)))
      .orderBy(asc(companies.name));
    const siteRows = await this.database
      .select()
      .from(sites)
      .where(and(eq(sites.organizationId, context.organizationId), eq(sites.active, true)))
      .orderBy(asc(sites.name));
    const peopleRows = await this.database
      .select()
      .from(people)
      .where(
        and(
          eq(people.organizationId, context.organizationId),
          eq(people.active, true),
          ne(people.name, "Responsável pelo preenchimento"),
        ),
      )
      .orderBy(asc(people.name));
    const [last] = await this.database
      .select({ sequence: syncChangeLog.sequence })
      .from(syncChangeLog)
      .where(eq(syncChangeLog.organizationId, context.organizationId))
      .orderBy(desc(syncChangeLog.sequence))
      .limit(1);
    return {
      serverTime: new Date().toISOString(),
      cursor: String(last?.sequence ?? 0),
      timezone: process.env.DEFAULT_TIMEZONE ?? "America/Fortaleza",
      weekStartsOn: "MONDAY",
      templateVersions: templateVersionsData,
      assets: assetRows,
      operationConfigs: configs,
      assetTemplateAssignments: assignments,
      companies: companyRows,
      sites: siteRows,
      people: peopleRows,
      tombstones: [],
    };
  }

  async push(context: AuthContext, input: PushInput) {
    const results = [];
    for (const operation of input.operations) {
      try {
        if (operation.entityType === "AUDIT_EVENT") {
          if (!hasPermission(context.roles, "inspections:write"))
            throw new DomainError("FORBIDDEN", "Sem permissão para registrar inspeções.", 403);
          if (operation.mutation !== "VOID" || operation.baseRevision != null)
            throw new DomainError("VALIDATION_FAILED", "Evento de auditoria inválido.", 422);
          const details = z
            .object({ localDate: z.iso.date(), assetCode: z.string().max(100) })
            .parse(operation.payload);
          const requestHash = hashPayload({
            entityId: operation.entityId,
            details,
            clientOccurredAt: operation.clientOccurredAt,
            deviceId: input.deviceId,
          });
          const inserted = await this.database
            .insert(auditEvents)
            .values({
              id: operation.operationId,
              organizationId: context.organizationId,
              entityType: "INSPECTION",
              entityId: operation.entityId,
              action: "LOCAL_DRAFT_DEACTIVATED",
              actorUserId: context.userId,
              metadata: {
                ...details,
                clientOccurredAt: operation.clientOccurredAt,
                deviceId: input.deviceId,
                source: "MOBILE",
                requestHash,
              },
            })
            .onConflictDoNothing({ target: auditEvents.id })
            .returning({ id: auditEvents.id });
          if (!inserted.length) {
            const [previous] = await this.database
              .select()
              .from(auditEvents)
              .where(eq(auditEvents.id, operation.operationId))
              .limit(1);
            if (
              !previous ||
              previous.organizationId !== context.organizationId ||
              previous.actorUserId !== context.userId ||
              previous.metadata.requestHash !== requestHash
            ) {
              throw new DomainError(
                "AUDIT_OPERATION_REUSED",
                "O identificador do evento já foi usado com outro conteúdo.",
                409,
              );
            }
          }
          results.push({
            operationId: operation.operationId,
            status: inserted.length ? "APPLIED" : "ALREADY_APPLIED",
            entityId: operation.entityId,
            serverRevision: null,
            problem: null,
          });
        } else if (
          operation.entityType === "COMPANY" ||
          operation.entityType === "SITE" ||
          operation.entityType === "PERSON" ||
          operation.entityType === "ASSET"
        ) {
          if (!hasPermission(context.roles, "cadastros:write"))
            throw new DomainError("FORBIDDEN", "Sem permissão para cadastrar.", 403);
          if (operation.mutation !== "UPSERT" || operation.baseRevision != null)
            throw new DomainError("VALIDATION_FAILED", "Operação de cadastro inválida.", 422);
          const kinds = {
            COMPANY: "companies",
            SITE: "sites",
            PERSON: "people",
            ASSET: "assets",
          } as const;
          const created = await new PostgresRegistryRepository().createFromSync(
            context,
            kinds[operation.entityType],
            operation.entityId,
            operation.payload,
          );
          results.push({
            operationId: operation.operationId,
            status: "APPLIED",
            entityId: created.id,
            serverRevision: created.revision,
            problem: null,
          });
        } else if (operation.entityType === "WEEKLY_CHECKLIST") {
          const weekly = await this.checklists.openWeekly(
            context,
            openWeeklyChecklistSchema.parse(operation.payload),
          );
          results.push({
            operationId: operation.operationId,
            status: "APPLIED",
            entityId: weekly.id,
            serverRevision: weekly.revision,
            problem: null,
          });
        } else if (operation.baseRevision == null) {
          const inspectionInput = createInspectionSchema.parse({
            ...operation.payload,
            clientInspectionId: operation.entityId,
            deviceId: input.deviceId,
          });
          const weeklyChecklistId = String(operation.payload.weeklyChecklistId ?? "");
          const outcome = await this.checklists.createInspection(
            context,
            weeklyChecklistId,
            operation.operationId,
            inspectionInput,
          );
          results.push({
            operationId: operation.operationId,
            status:
              outcome.statusCode === 409
                ? "CONFLICT"
                : outcome.replayed
                  ? "ALREADY_APPLIED"
                  : "APPLIED",
            entityId: outcome.result.id,
            serverRevision: outcome.result.revision,
            problem:
              outcome.statusCode === 409
                ? { code: "DUPLICATE_SLOT", conflictId: outcome.result.conflictId }
                : null,
          });
        } else if (operation.mutation === "UPSERT" || operation.mutation === "COMPLETE") {
          const inspectionInput = updateInspectionSchema.parse({
            ...operation.payload,
            operationId: operation.operationId,
            deviceId: input.deviceId,
            baseRevision: operation.baseRevision,
            lifecycleStatus:
              operation.mutation === "COMPLETE" ? "COMPLETED" : operation.payload.lifecycleStatus,
          });
          const updated = await this.checklists.updateInspection(
            context,
            operation.entityId,
            inspectionInput,
          );
          results.push({
            operationId: operation.operationId,
            status: "APPLIED",
            entityId: updated.id,
            serverRevision: updated.revision,
            problem: null,
          });
        } else {
          throw new Error("A anulação de inspeções ainda não está disponível no aplicativo.");
        }
      } catch (error) {
        const detail =
          error instanceof ZodError
            ? `${error.issues[0]?.path.join("/") || "payload"}: ${error.issues[0]?.message ?? "Dado inválido."}`
            : error instanceof Error
              ? error.message
              : "Falha desconhecida";
        results.push({
          operationId: operation.operationId,
          status: "REJECTED",
          entityId: operation.entityId,
          serverRevision: null,
          problem: { code: error instanceof Error ? error.name : "ERROR", detail },
        });
      }
    }
    return { serverTime: new Date().toISOString(), results };
  }

  async pull(context: AuthContext, cursor: number, limit: number) {
    const rows = await this.database
      .select()
      .from(syncChangeLog)
      .where(eq(syncChangeLog.organizationId, context.organizationId))
      .orderBy(asc(syncChangeLog.sequence));
    const changesAfter = rows.filter((row) => row.sequence > cursor).slice(0, limit + 1);
    const page = changesAfter.slice(0, limit);
    return {
      serverTime: new Date().toISOString(),
      nextCursor: String(page.at(-1)?.sequence ?? cursor),
      hasMore: changesAfter.length > limit,
      changes: page
        .filter((row) => row.changeType !== "ARCHIVE" && row.changeType !== "DELETE")
        .map((row) => ({
          entityType: row.entityType,
          entityId: row.entityId,
          revision: row.revision,
          payload: row.payload,
        })),
      tombstones: page
        .filter((row) => row.changeType === "ARCHIVE" || row.changeType === "DELETE")
        .map((row) => ({
          entityType: row.entityType,
          entityId: row.entityId,
          deletedAt: row.changedAt.toISOString(),
          changeType: row.changeType,
        })),
    };
  }
}
