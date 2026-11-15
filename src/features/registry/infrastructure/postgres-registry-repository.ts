import { and, asc, eq } from "drizzle-orm";
import { getDb } from "@/infrastructure/db/client";
import {
  assetRevisions,
  assets,
  assetTemplateAssignments,
  auditEvents,
  companies,
  operationConfigs,
  people,
  sites
} from "@/infrastructure/db/schema";

type Context = { organizationId: string; userId: string };

export class PostgresRegistryRepository {
  private get database() { return getDb(); }

  listCompanies(context: Context) {
    return this.database.select().from(companies).where(eq(companies.organizationId, context.organizationId)).orderBy(asc(companies.name));
  }
  createCompany(context: Context, input: { name: string; document?: string | null }) {
    return this.database.transaction(async (tx) => {
      const [created] = await tx.insert(companies).values({ organizationId: context.organizationId, ...input }).returning();
      await tx.insert(auditEvents).values({ organizationId: context.organizationId, entityType: "COMPANY", entityId: created.id, action: "CREATED", actorUserId: context.userId });
      return created;
    });
  }
  listSites(context: Context) {
    return this.database.select().from(sites).where(eq(sites.organizationId, context.organizationId)).orderBy(asc(sites.name));
  }
  createSite(context: Context, input: { companyId: string; name: string }) {
    return this.database.transaction(async (tx) => {
      const [created] = await tx.insert(sites).values({ organizationId: context.organizationId, ...input }).returning();
      await tx.insert(auditEvents).values({ organizationId: context.organizationId, entityType: "SITE", entityId: created.id, action: "CREATED", actorUserId: context.userId });
      return created;
    });
  }
  listPeople(context: Context) {
    return this.database.select().from(people).where(eq(people.organizationId, context.organizationId)).orderBy(asc(people.name));
  }
  createPerson(context: Context, input: Omit<typeof people.$inferInsert, "id" | "organizationId" | "createdAt" | "updatedAt">) {
    return this.database.transaction(async (tx) => {
      const [created] = await tx.insert(people).values({ organizationId: context.organizationId, ...input }).returning();
      await tx.insert(auditEvents).values({ organizationId: context.organizationId, entityType: "PERSON", entityId: created.id, action: "CREATED", actorUserId: context.userId });
      return created;
    });
  }
  listAssets(context: Context) {
    return this.database
      .select({ asset: assets, siteName: sites.name, companyName: companies.name })
      .from(assets)
      .innerJoin(companies, eq(companies.id, assets.companyId))
      .leftJoin(sites, eq(sites.id, assets.siteId))
      .where(eq(assets.organizationId, context.organizationId))
      .orderBy(asc(assets.code));
  }
  createAsset(context: Context, input: Omit<typeof assets.$inferInsert, "id" | "organizationId" | "revision" | "active" | "createdAt" | "updatedAt">) {
    return this.database.transaction(async (tx) => {
      const [created] = await tx.insert(assets).values({ organizationId: context.organizationId, ...input }).returning();
      await tx.insert(assetRevisions).values({ assetId: created.id, revision: 1, snapshot: created, changedBy: context.userId });
      await tx.insert(auditEvents).values({ organizationId: context.organizationId, entityType: "ASSET", entityId: created.id, action: "CREATED", actorUserId: context.userId });
      return created;
    });
  }
  async assignTemplate(context: Context, assetId: string, input: { templateId: string; operationConfigId: string }) {
    return this.database.transaction(async (tx) => {
      const [config] = await tx
        .select()
        .from(operationConfigs)
        .where(and(eq(operationConfigs.id, input.operationConfigId), eq(operationConfigs.organizationId, context.organizationId)))
        .limit(1);
      if (!config || config.templateId !== input.templateId) throw new Error("Configuração incompatível com o modelo.");
      const [assignment] = await tx
        .insert(assetTemplateAssignments)
        .values({ organizationId: context.organizationId, assetId, ...input })
        .onConflictDoUpdate({
          target: [assetTemplateAssignments.assetId, assetTemplateAssignments.templateId],
          set: { operationConfigId: input.operationConfigId, active: true, updatedAt: new Date() }
        })
        .returning();
      await tx.insert(auditEvents).values({ organizationId: context.organizationId, entityType: "ASSET_TEMPLATE_ASSIGNMENT", entityId: assignment.id, action: "UPSERTED", actorUserId: context.userId });
      return assignment;
    });
  }
}
