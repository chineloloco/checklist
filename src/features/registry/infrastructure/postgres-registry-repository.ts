import { and, asc, eq, ne, sql } from "drizzle-orm";
import { conflict, notFound, validationFailed } from "@/shared/domain/errors";
import {
  createAssetSchema,
  createCompanySchema,
  createPersonSchema,
  createSiteSchema,
  type RegistryKind,
} from "@/features/registry/domain/registry";
import { getDb } from "@/infrastructure/db/client";
import {
  assetRevisions,
  assets,
  assetTemplateAssignments,
  auditEvents,
  companies,
  operationConfigs,
  people,
  sites,
  syncChangeLog,
} from "@/infrastructure/db/schema";

type Context = { organizationId: string; userId: string };

export class PostgresRegistryRepository {
  private get database() {
    return getDb();
  }

  async createFromSync(context: Context, kind: RegistryKind, id: string, input: unknown) {
    return this.database.transaction(async (tx) => {
      await tx.execute(sql`select pg_advisory_xact_lock(hashtext(${`registry:${kind}:${id}`}))`);
      const table = { companies, sites, people, assets }[kind];
      const [existing] = await tx
        .select({ id: table.id, organizationId: table.organizationId })
        .from(table)
        .where(eq(table.id, id));
      if (existing) {
        if (existing.organizationId !== context.organizationId)
          throw conflict("REGISTRY_ID_CONFLICT", "Identificador de cadastro indisponível.");
        return { id: existing.id, revision: 1 };
      }
      const requireCompany = async (companyId: string) => {
        const [company] = await tx
          .select({ id: companies.id })
          .from(companies)
          .where(
            and(
              eq(companies.id, companyId),
              eq(companies.organizationId, context.organizationId),
              eq(companies.active, true),
            ),
          )
          .for("share");
        if (!company) throw validationFailed("Selecione uma empresa ativa da organização.");
      };
      const base = { id, organizationId: context.organizationId };
      let created: { id: string; revision?: number } & Record<string, unknown>;
      if (kind === "companies") {
        [created] = await tx
          .insert(companies)
          .values({ ...base, ...createCompanySchema.parse(input) })
          .returning();
      } else if (kind === "sites") {
        const data = createSiteSchema.parse(input);
        if (data.companyId) await requireCompany(data.companyId);
        [created] = await tx
          .insert(sites)
          .values({ ...base, ...data })
          .returning();
      } else if (kind === "people") {
        [created] = await tx
          .insert(people)
          .values({ ...base, ...createPersonSchema.parse(input) })
          .returning();
      } else {
        const data = createAssetSchema.parse(input);
        await requireCompany(data.companyId);
        if (data.siteId) {
          const [site] = await tx
            .select({ companyId: sites.companyId })
            .from(sites)
            .where(
              and(
                eq(sites.id, data.siteId),
                eq(sites.organizationId, context.organizationId),
                eq(sites.active, true),
              ),
            )
            .for("share");
          if (!site || (site.companyId !== null && site.companyId !== data.companyId))
            throw validationFailed("O local deve pertencer à empresa selecionada.");
        }
        [created] = await tx
          .insert(assets)
          .values({ ...base, ...data })
          .returning();
        await tx
          .insert(assetRevisions)
          .values({ assetId: id, revision: 1, snapshot: created, changedBy: context.userId });
      }
      const entityType = { companies: "COMPANY", sites: "SITE", people: "PERSON", assets: "ASSET" }[
        kind
      ];
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType,
        entityId: id,
        action: "CREATED",
        actorUserId: context.userId,
      });
      await tx.insert(syncChangeLog).values({
        organizationId: context.organizationId,
        entityType,
        entityId: id,
        revision: 1,
        changeType: "UPSERT",
        payload: created,
      });
      return { id: created.id, revision: created.revision ?? 1 };
    });
  }

  async mutate(context: Context, kind: RegistryKind, id: string, input: unknown | null) {
    return this.database.transaction(async (tx) => {
      const table = { companies, sites, people, assets }[kind];
      const [existing] = await tx
        .select({ id: table.id })
        .from(table)
        .where(
          and(
            eq(table.id, id),
            eq(table.organizationId, context.organizationId),
            eq(table.active, true),
          ),
        )
        .for("update");
      if (!existing) throw notFound("Cadastro não encontrado.");
      const removing = input === null;
      const now = new Date();
      const scope = and(eq(table.id, id), eq(table.organizationId, context.organizationId));
      const requireCompany = async (companyId: string) => {
        const [company] = await tx
          .select({ id: companies.id })
          .from(companies)
          .where(
            and(
              eq(companies.id, companyId),
              eq(companies.organizationId, context.organizationId),
              eq(companies.active, true),
            ),
          )
          .for("share");
        if (!company) throw validationFailed("Selecione uma empresa ativa da organização.");
      };
      let updated: { id: string; revision?: number } & Record<string, unknown>;
      if (kind === "companies") {
        if (removing) {
          const linkedSites = await tx
            .select({ id: sites.id })
            .from(sites)
            .where(and(eq(sites.companyId, id), eq(sites.active, true)))
            .limit(1);
          const linkedAssets = await tx
            .select({ id: assets.id })
            .from(assets)
            .where(and(eq(assets.companyId, id), eq(assets.active, true)))
            .limit(1);
          if (linkedSites.length || linkedAssets.length)
            throw conflict(
              "REGISTRY_IN_USE",
              "Remova ou transfira os locais e ativos desta empresa antes de excluí-la.",
            );
        }
        [updated] = await tx
          .update(companies)
          .set(
            removing
              ? { active: false, updatedAt: now }
              : { ...createCompanySchema.parse(input), updatedAt: now },
          )
          .where(scope)
          .returning();
      } else if (kind === "sites") {
        const linked = await tx
          .select({ companyId: assets.companyId })
          .from(assets)
          .where(and(eq(assets.siteId, id), eq(assets.active, true)));
        const data = removing ? null : createSiteSchema.parse(input);
        if (removing && linked.length)
          throw conflict(
            "REGISTRY_IN_USE",
            "Remova ou transfira os ativos deste local antes de excluí-lo.",
          );
        if (data?.companyId) {
          await requireCompany(data.companyId);
          if (linked.some((asset) => asset.companyId !== data.companyId))
            throw conflict(
              "REGISTRY_IN_USE",
              "Transfira os ativos antes de alterar a empresa deste local.",
            );
        }
        [updated] = await tx
          .update(sites)
          .set(data ? { ...data, updatedAt: now } : { active: false, updatedAt: now })
          .where(scope)
          .returning();
      } else if (kind === "people") {
        [updated] = await tx
          .update(people)
          .set(
            removing
              ? { active: false, updatedAt: now }
              : { ...createPersonSchema.parse(input), updatedAt: now },
          )
          .where(scope)
          .returning();
      } else {
        const data = removing ? null : createAssetSchema.parse(input);
        if (data) {
          await requireCompany(data.companyId);
          if (data.siteId) {
            const [site] = await tx
              .select({ companyId: sites.companyId })
              .from(sites)
              .where(
                and(
                  eq(sites.id, data.siteId),
                  eq(sites.organizationId, context.organizationId),
                  eq(sites.active, true),
                ),
              )
              .for("share");
            if (!site || (site.companyId !== null && site.companyId !== data.companyId))
              throw validationFailed("O local deve pertencer à empresa selecionada.");
          }
        }
        [updated] = await tx
          .update(assets)
          .set({
            ...(data ?? { active: false }),
            revision: sql`${assets.revision} + 1`,
            updatedAt: now,
          })
          .where(scope)
          .returning();
        await tx.insert(assetRevisions).values({
          assetId: id,
          revision: updated.revision!,
          snapshot: updated,
          changedBy: context.userId,
        });
        if (removing)
          await tx
            .update(assetTemplateAssignments)
            .set({ active: false, updatedAt: now })
            .where(eq(assetTemplateAssignments.assetId, id));
      }
      const entityType = { companies: "COMPANY", sites: "SITE", people: "PERSON", assets: "ASSET" }[
        kind
      ];
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType,
        entityId: id,
        action: removing ? "ARCHIVED" : "UPDATED",
        actorUserId: context.userId,
      });
      await tx.insert(syncChangeLog).values({
        organizationId: context.organizationId,
        entityType,
        entityId: id,
        revision: updated.revision ?? 1,
        changeType: removing ? "ARCHIVE" : "UPSERT",
        payload: updated,
      });
      return updated;
    });
  }

  listCompanies(context: Context) {
    return this.database
      .select()
      .from(companies)
      .where(eq(companies.organizationId, context.organizationId))
      .orderBy(asc(companies.name));
  }
  createCompany(context: Context, input: { name: string; document?: string | null }) {
    return this.database.transaction(async (tx) => {
      const [created] = await tx
        .insert(companies)
        .values({ organizationId: context.organizationId, ...input })
        .returning();
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "COMPANY",
        entityId: created.id,
        action: "CREATED",
        actorUserId: context.userId,
      });
      return created;
    });
  }
  listSites(context: Context) {
    return this.database
      .select()
      .from(sites)
      .where(eq(sites.organizationId, context.organizationId))
      .orderBy(asc(sites.name));
  }
  createSite(context: Context, input: { companyId?: string | null; name: string }) {
    return this.database.transaction(async (tx) => {
      if (input.companyId) {
        const [company] = await tx
          .select({ id: companies.id })
          .from(companies)
          .where(
            and(
              eq(companies.id, input.companyId),
              eq(companies.organizationId, context.organizationId),
              eq(companies.active, true),
            ),
          )
          .for("share");
        if (!company) throw validationFailed("Selecione uma empresa ativa da organização.");
      }
      const [created] = await tx
        .insert(sites)
        .values({ organizationId: context.organizationId, ...input })
        .returning();
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "SITE",
        entityId: created.id,
        action: "CREATED",
        actorUserId: context.userId,
      });
      return created;
    });
  }
  listPeople(context: Context, includeInactive = false) {
    return this.database
      .select()
      .from(people)
      .where(
        and(
          eq(people.organizationId, context.organizationId),
          includeInactive ? undefined : eq(people.active, true),
          ne(people.name, "Responsável pelo preenchimento"),
        ),
      )
      .orderBy(asc(people.name));
  }
  createPerson(
    context: Context,
    input: Omit<typeof people.$inferInsert, "id" | "organizationId" | "createdAt" | "updatedAt">,
  ) {
    return this.database.transaction(async (tx) => {
      const [created] = await tx
        .insert(people)
        .values({ organizationId: context.organizationId, ...input })
        .returning();
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "PERSON",
        entityId: created.id,
        action: "CREATED",
        actorUserId: context.userId,
      });
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
  createAsset(
    context: Context,
    input: Omit<
      typeof assets.$inferInsert,
      "id" | "organizationId" | "revision" | "active" | "createdAt" | "updatedAt"
    >,
  ) {
    return this.database.transaction(async (tx) => {
      const [company] = await tx
        .select({ id: companies.id })
        .from(companies)
        .where(
          and(
            eq(companies.id, input.companyId),
            eq(companies.organizationId, context.organizationId),
            eq(companies.active, true),
          ),
        )
        .for("share");
      if (!company) throw validationFailed("Selecione uma empresa ativa da organização.");
      if (input.siteId) {
        const [site] = await tx
          .select({ companyId: sites.companyId })
          .from(sites)
          .where(
            and(
              eq(sites.id, input.siteId),
              eq(sites.organizationId, context.organizationId),
              eq(sites.active, true),
            ),
          )
          .for("share");
        if (!site || (site.companyId !== null && site.companyId !== input.companyId))
          throw validationFailed("O local deve pertencer à empresa selecionada.");
      }
      const [created] = await tx
        .insert(assets)
        .values({ organizationId: context.organizationId, ...input })
        .returning();
      await tx
        .insert(assetRevisions)
        .values({ assetId: created.id, revision: 1, snapshot: created, changedBy: context.userId });
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "ASSET",
        entityId: created.id,
        action: "CREATED",
        actorUserId: context.userId,
      });
      return created;
    });
  }
  async assignTemplate(
    context: Context,
    assetId: string,
    input: { templateId: string; operationConfigId: string },
  ) {
    return this.database.transaction(async (tx) => {
      const [config] = await tx
        .select()
        .from(operationConfigs)
        .where(
          and(
            eq(operationConfigs.id, input.operationConfigId),
            eq(operationConfigs.organizationId, context.organizationId),
          ),
        )
        .limit(1);
      if (!config || config.templateId !== input.templateId)
        throw new Error("Configuração incompatível com o modelo.");
      const [assignment] = await tx
        .insert(assetTemplateAssignments)
        .values({ organizationId: context.organizationId, assetId, ...input })
        .onConflictDoUpdate({
          target: [assetTemplateAssignments.assetId, assetTemplateAssignments.templateId],
          set: { operationConfigId: input.operationConfigId, active: true, updatedAt: new Date() },
        })
        .returning();
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "ASSET_TEMPLATE_ASSIGNMENT",
        entityId: assignment.id,
        action: "UPSERTED",
        actorUserId: context.userId,
      });
      await tx.insert(syncChangeLog).values({
        organizationId: context.organizationId,
        entityType: "ASSET_TEMPLATE_ASSIGNMENT",
        entityId: assignment.id,
        revision: 1,
        changeType: "UPSERT",
        payload: assignment,
      });
      return assignment;
    });
  }
}
