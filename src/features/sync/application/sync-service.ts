import { and, asc, desc, eq } from "drizzle-orm";
import type { AuthContext } from "@/features/auth/application/auth-context";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { createInspectionSchema, openWeeklyChecklistSchema } from "@/features/checklists/domain/inspection";
import type { z } from "zod";
import type { syncPushSchema } from "@/features/sync/domain/sync";
import { getDb } from "@/infrastructure/db/client";
import {
  assets,
  operationConfigs,
  syncChangeLog,
  templateVersions
} from "@/infrastructure/db/schema";
import { TemplateService } from "@/features/templates/application/template-service";

type PushInput = z.infer<typeof syncPushSchema>;

export class SyncService {
  private get database() { return getDb(); }
  private readonly checklists = new ChecklistService();
  private readonly templates = new TemplateService();

  async bootstrap(context: AuthContext, sinceCursor?: number) {
    if (sinceCursor) return this.pull(context, sinceCursor, 500);
    const versions = await this.database
      .select({ id: templateVersions.id })
      .from(templateVersions)
      .where(
        and(
          eq(templateVersions.status, "PUBLISHED"),
          eq(templateVersions.organizationId, context.organizationId)
        )
      );
    const templateVersionsData = [];
    for (const version of versions) templateVersionsData.push(await this.templates.version(context, version.id));
    const assetRows = await this.database.select().from(assets).where(eq(assets.organizationId, context.organizationId));
    const configs = await this.database.select().from(operationConfigs).where(eq(operationConfigs.organizationId, context.organizationId));
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
      tombstones: []
    };
  }

  async push(context: AuthContext, input: PushInput) {
    const results = [];
    for (const operation of input.operations) {
      try {
        if (operation.entityType === "WEEKLY_CHECKLIST") {
          const weekly = await this.checklists.openWeekly(context, openWeeklyChecklistSchema.parse(operation.payload));
          results.push({ operationId: operation.operationId, status: "APPLIED", entityId: weekly.id, serverRevision: weekly.revision, problem: null });
        } else {
          const inspectionInput = createInspectionSchema.parse({
            ...operation.payload,
            clientInspectionId: operation.entityId,
            deviceId: input.deviceId
          });
          const weeklyChecklistId = String(operation.payload.weeklyChecklistId ?? "");
          const outcome = await this.checklists.createInspection(context, weeklyChecklistId, operation.operationId, inspectionInput);
          results.push({
            operationId: operation.operationId,
            status: outcome.statusCode === 409 ? "CONFLICT" : outcome.replayed ? "ALREADY_APPLIED" : "APPLIED",
            entityId: outcome.result.id,
            serverRevision: outcome.result.revision,
            problem: outcome.statusCode === 409 ? { code: "DUPLICATE_SLOT", conflictId: outcome.result.conflictId } : null
          });
        }
      } catch (error) {
        results.push({
          operationId: operation.operationId,
          status: "REJECTED",
          entityId: operation.entityId,
          serverRevision: null,
          problem: { code: error instanceof Error ? error.name : "ERROR", detail: error instanceof Error ? error.message : "Falha desconhecida" }
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
        .map((row) => ({ entityType: row.entityType, entityId: row.entityId, revision: row.revision, payload: row.payload })),
      tombstones: page
        .filter((row) => row.changeType === "ARCHIVE" || row.changeType === "DELETE")
        .map((row) => ({ entityType: row.entityType, entityId: row.entityId, deletedAt: row.changedAt.toISOString(), changeType: row.changeType }))
    };
  }
}
