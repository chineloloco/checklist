import { createHash, randomUUID } from "node:crypto";
import { and, asc, count, desc, eq, sql } from "drizzle-orm";
import { getDb } from "@/infrastructure/db/client";
import {
  auditEvents,
  assetTemplateAssignments,
  checklistTemplates,
  operationConfigs,
  organizations,
  syncChangeLog,
  templateItems,
  templateSections,
  templateVersions,
  weeklyChecklists,
} from "@/infrastructure/db/schema";
import { conflict, notFound, validationFailed } from "@/shared/domain/errors";
import type {
  CreateTemplateInput,
  UpdateTemplateMetadataInput,
  UpdateTemplateVersionInput,
} from "@/features/templates/domain/template";

type Context = { organizationId: string; userId: string };

export class PostgresTemplateRepository {
  private get database() {
    return getDb();
  }

  async list(context: Context, status?: "DRAFT" | "ACTIVE" | "ARCHIVED") {
    const conditions = [eq(checklistTemplates.organizationId, context.organizationId)];
    if (status) conditions.push(eq(checklistTemplates.status, status));
    return this.database
      .select({
        id: checklistTemplates.id,
        code: checklistTemplates.code,
        name: checklistTemplates.name,
        assetKind: checklistTemplates.assetKind,
        status: checklistTemplates.status,
        identificationStatus: checklistTemplates.identificationStatus,
        latestVersion: sql<number>`max(${templateVersions.versionNumber})`,
        publishedVersions: sql<number>`count(*) filter (where ${templateVersions.status} = 'PUBLISHED')`,
      })
      .from(checklistTemplates)
      .leftJoin(templateVersions, eq(templateVersions.templateId, checklistTemplates.id))
      .where(and(...conditions))
      .groupBy(checklistTemplates.id)
      .orderBy(asc(checklistTemplates.code));
  }

  async detail(context: Context, templateId: string) {
    const [template] = await this.database
      .select()
      .from(checklistTemplates)
      .where(
        and(
          eq(checklistTemplates.id, templateId),
          eq(checklistTemplates.organizationId, context.organizationId),
        ),
      )
      .limit(1);
    if (!template) throw notFound("Modelo não encontrado.");
    const versions = await this.database
      .select()
      .from(templateVersions)
      .where(eq(templateVersions.templateId, templateId))
      .orderBy(desc(templateVersions.versionNumber));
    return { ...template, versions };
  }

  async version(context: Context, versionId: string) {
    const [version] = await this.database
      .select({ version: templateVersions, template: checklistTemplates })
      .from(templateVersions)
      .innerJoin(checklistTemplates, eq(checklistTemplates.id, templateVersions.templateId))
      .where(
        and(
          eq(templateVersions.id, versionId),
          eq(templateVersions.organizationId, context.organizationId),
        ),
      )
      .limit(1);
    if (!version) throw notFound("Versão não encontrada.");
    const sections = await this.database
      .select()
      .from(templateSections)
      .where(eq(templateSections.versionId, versionId))
      .orderBy(asc(templateSections.sortOrder));
    const items = await this.database
      .select()
      .from(templateItems)
      .where(eq(templateItems.versionId, versionId))
      .orderBy(asc(templateItems.sortOrder));
    return {
      ...version.version,
      template: version.template,
      sections: sections.map((section) => ({
        ...section,
        items: items.filter((item) => item.sectionId === section.id),
      })),
    };
  }

  async create(context: Context, input: CreateTemplateInput) {
    const versionId = await this.database.transaction(async (tx) => {
      const [template] = await tx
        .insert(checklistTemplates)
        .values({
          organizationId: context.organizationId,
          code: input.code,
          name: input.name,
          assetKind: input.assetKind,
          status: "DRAFT",
          identificationStatus: input.name ? "CONFIRMED" : "PENDING_CONFIRMATION",
        })
        .returning();
      const [version] = await tx
        .insert(templateVersions)
        .values({
          organizationId: context.organizationId,
          templateId: template.id,
          versionNumber: 1,
          status: "DRAFT",
          identificationFields: input.identificationFields,
        })
        .returning();
      await this.writeSections(tx, version.id, input.sections);
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "TEMPLATE",
        entityId: template.id,
        action: "DRAFT_CREATED",
        actorUserId: context.userId,
      });
      return version.id;
    });
    return this.version(context, versionId);
  }

  async updateDraft(context: Context, versionId: string, input: UpdateTemplateVersionInput) {
    await this.database.transaction(async (tx) => {
      await tx.execute(
        sql`select pg_advisory_xact_lock(hashtext(${`template-version:${versionId}`}))`,
      );
      const [version] = await tx
        .select()
        .from(templateVersions)
        .where(
          and(
            eq(templateVersions.id, versionId),
            eq(templateVersions.organizationId, context.organizationId),
          ),
        )
        .limit(1);
      if (!version) throw notFound("Versão não encontrada.");
      if (version.status !== "DRAFT")
        throw conflict("VERSION_IMMUTABLE", "Versões publicadas não podem ser alteradas.");
      if (version.revision !== input.baseRevision) {
        throw conflict("REVISION_CONFLICT", "A versão foi alterada em outro lugar.", {
          currentRevision: version.revision,
        });
      }

      await tx.delete(templateItems).where(eq(templateItems.versionId, versionId));
      await tx.delete(templateSections).where(eq(templateSections.versionId, versionId));
      await this.writeSections(tx, versionId, input.sections);
      await tx
        .update(templateVersions)
        .set({
          identificationFields: input.identificationFields,
          revision: version.revision + 1,
          updatedAt: new Date(),
        })
        .where(eq(templateVersions.id, versionId));
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "TEMPLATE_VERSION",
        entityId: versionId,
        action: "DRAFT_UPDATED",
        actorUserId: context.userId,
        metadata: { revision: version.revision + 1 },
      });
    });
    return this.version(context, versionId);
  }

  async updateMetadata(context: Context, templateId: string, input: UpdateTemplateMetadataInput) {
    return this.database.transaction(async (tx) => {
      const [template] = await tx
        .select()
        .from(checklistTemplates)
        .where(
          and(
            eq(checklistTemplates.id, templateId),
            eq(checklistTemplates.organizationId, context.organizationId),
          ),
        )
        .limit(1);
      if (!template) throw notFound("Modelo não encontrado.");
      if (template.status === "ARCHIVED")
        throw conflict("TEMPLATE_ARCHIVED", "Modelos arquivados não podem ser alterados.");

      const [updated] = await tx
        .update(checklistTemplates)
        .set({ name: input.name, identificationStatus: "CONFIRMED", updatedAt: new Date() })
        .where(eq(checklistTemplates.id, templateId))
        .returning();
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "TEMPLATE",
        entityId: templateId,
        action: "IDENTIFICATION_CONFIRMED",
        actorUserId: context.userId,
        metadata: { previousName: template.name, name: input.name },
      });
      return updated;
    });
  }

  async createVersion(context: Context, templateId: string, basedOnVersionId: string) {
    const versionId = await this.database.transaction(async (tx) => {
      const [base] = await tx
        .select()
        .from(templateVersions)
        .where(
          and(
            eq(templateVersions.id, basedOnVersionId),
            eq(templateVersions.templateId, templateId),
            eq(templateVersions.organizationId, context.organizationId),
          ),
        )
        .limit(1);
      if (!base) throw notFound("Versão base não encontrada.");
      const [existingDraft] = await tx
        .select()
        .from(templateVersions)
        .where(
          and(eq(templateVersions.templateId, templateId), eq(templateVersions.status, "DRAFT")),
        )
        .limit(1);
      if (existingDraft)
        throw conflict(
          "DRAFT_ALREADY_EXISTS",
          "Já existe uma versão em rascunho para este modelo.",
          { versionId: existingDraft.id },
        );
      const [latest] = await tx
        .select({ versionNumber: sql<number>`max(${templateVersions.versionNumber})` })
        .from(templateVersions)
        .where(eq(templateVersions.templateId, templateId));
      const [created] = await tx
        .insert(templateVersions)
        .values({
          organizationId: context.organizationId,
          templateId,
          versionNumber: Number(latest.versionNumber ?? 0) + 1,
          status: "DRAFT",
          identificationFields: base.identificationFields,
        })
        .returning();
      const sections = await tx
        .select()
        .from(templateSections)
        .where(eq(templateSections.versionId, base.id))
        .orderBy(asc(templateSections.sortOrder));
      const items = await tx
        .select()
        .from(templateItems)
        .where(eq(templateItems.versionId, base.id))
        .orderBy(asc(templateItems.sortOrder));
      let order = 0;
      for (const section of sections) {
        const sectionId = randomUUID();
        await tx.insert(templateSections).values({
          id: sectionId,
          versionId: created.id,
          title: section.title,
          sortOrder: section.sortOrder,
        });
        const sectionItems = items.filter((item) => item.sectionId === section.id);
        if (sectionItems.length) {
          await tx.insert(templateItems).values(
            sectionItems.map((item) => ({
              id: randomUUID(),
              sectionId,
              versionId: created.id,
              sourcePrintedNumber: item.sourcePrintedNumber,
              originalText: item.originalText,
              sortOrder: order++,
              requiredOnComplete: item.requiredOnComplete,
              requireObservationWhenNc: item.requireObservationWhenNc,
              requirePhotoWhenNc: item.requirePhotoWhenNc,
            })),
          );
        }
      }
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "TEMPLATE_VERSION",
        entityId: created.id,
        action: "DRAFT_CREATED",
        actorUserId: context.userId,
        metadata: { basedOnVersionId },
      });
      return created.id;
    });
    return this.version(context, versionId);
  }

  async publish(context: Context, versionId: string, baseRevision: number) {
    return this.database.transaction(async (tx) => {
      await tx.execute(
        sql`select pg_advisory_xact_lock(hashtext(${`template-version:${versionId}`}))`,
      );
      const [row] = await tx
        .select({ version: templateVersions, template: checklistTemplates })
        .from(templateVersions)
        .innerJoin(checklistTemplates, eq(checklistTemplates.id, templateVersions.templateId))
        .where(
          and(
            eq(templateVersions.id, versionId),
            eq(templateVersions.organizationId, context.organizationId),
          ),
        )
        .limit(1);
      if (!row) throw notFound("Versão não encontrada.");
      if (row.version.status !== "DRAFT")
        throw conflict("VERSION_IMMUTABLE", "A versão já foi publicada ou arquivada.");
      if (row.version.revision !== baseRevision) {
        throw conflict("REVISION_CONFLICT", "A versão foi alterada em outro lugar.", {
          currentRevision: row.version.revision,
        });
      }
      if (!row.template.name || row.template.identificationStatus === "PENDING_CONFIRMATION") {
        throw validationFailed("Confirme a identificação do modelo antes da publicação.");
      }
      const [{ sectionCount }] = await tx
        .select({ sectionCount: count() })
        .from(templateSections)
        .where(eq(templateSections.versionId, versionId));
      const [{ itemCount }] = await tx
        .select({ itemCount: count() })
        .from(templateItems)
        .where(eq(templateItems.versionId, versionId));
      if (!sectionCount || !itemCount)
        throw validationFailed("A versão precisa de ao menos uma seção e um item.");

      const content = await this.version(context, versionId);
      const checksum = `sha256:${createHash("sha256").update(JSON.stringify(content.sections)).digest("hex")}`;
      const now = new Date();
      const [published] = await tx
        .update(templateVersions)
        .set({
          status: "PUBLISHED",
          checksum,
          publishedAt: now,
          publishedBy: context.userId,
          revision: row.version.revision + 1,
          updatedAt: now,
        })
        .where(eq(templateVersions.id, versionId))
        .returning();
      await tx
        .update(checklistTemplates)
        .set({ status: "ACTIVE", updatedAt: now })
        .where(eq(checklistTemplates.id, row.template.id));
      const [existingConfig] = await tx
        .select({ id: operationConfigs.id })
        .from(operationConfigs)
        .where(
          and(
            eq(operationConfigs.organizationId, context.organizationId),
            eq(operationConfigs.templateId, row.template.id),
            eq(operationConfigs.active, true),
          ),
        )
        .limit(1);
      if (!existingConfig) {
        const [organization] = await tx
          .select({
            timezone: organizations.timezone,
            weekStartsOn: organizations.weekStartsOn,
          })
          .from(organizations)
          .where(eq(organizations.id, context.organizationId))
          .limit(1);
        if (!organization) throw notFound("Organização não encontrada.");
        await tx.insert(operationConfigs).values({
          organizationId: context.organizationId,
          templateId: row.template.id,
          timezone: organization.timezone,
          weekStartsOn: organization.weekStartsOn,
          maxOccurrencesPerDate: 1,
          effectiveFrom: "2020-01-01",
        });
      }
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "TEMPLATE_VERSION",
        entityId: versionId,
        action: "PUBLISHED",
        actorUserId: context.userId,
        metadata: { checksum, versionNumber: published.versionNumber },
      });
      await tx.insert(syncChangeLog).values({
        organizationId: context.organizationId,
        entityType: "TEMPLATE_VERSION",
        entityId: versionId,
        revision: published.revision,
        changeType: "UPSERT",
        payload: {
          id: versionId,
          templateId: published.templateId,
          status: published.status,
          checksum,
        },
      });
      return published;
    });
  }

  async archive(context: Context, templateId: string) {
    return this.database.transaction(async (tx) => {
      const [template] = await tx
        .select()
        .from(checklistTemplates)
        .where(
          and(
            eq(checklistTemplates.id, templateId),
            eq(checklistTemplates.organizationId, context.organizationId),
          ),
        )
        .limit(1);
      if (!template) throw notFound("Modelo não encontrado.");
      const now = new Date();
      const [archived] = await tx
        .update(checklistTemplates)
        .set({ status: "ARCHIVED", archivedAt: now, archivedBy: context.userId, updatedAt: now })
        .where(eq(checklistTemplates.id, templateId))
        .returning();
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "TEMPLATE",
        entityId: templateId,
        action: "ARCHIVED",
        actorUserId: context.userId,
      });
      await tx.insert(syncChangeLog).values({
        organizationId: context.organizationId,
        entityType: "TEMPLATE",
        entityId: templateId,
        revision: 1,
        changeType: "ARCHIVE",
        payload: { id: templateId, archivedAt: now.toISOString() },
      });
      return archived;
    });
  }

  async deleteUnusedTemplate(context: Context, templateId: string) {
    return this.database.transaction(async (tx) => {
      const [template] = await tx
        .select({ id: checklistTemplates.id })
        .from(checklistTemplates)
        .where(
          and(
            eq(checklistTemplates.id, templateId),
            eq(checklistTemplates.organizationId, context.organizationId),
          ),
        )
        .for("update");
      if (!template) throw notFound("Modelo não encontrado.");
      const [usage] = await tx
        .select({ count: count() })
        .from(weeklyChecklists)
        .where(eq(weeklyChecklists.templateId, templateId));
      if (usage.count) {
        throw conflict("TEMPLATE_HAS_HISTORY", "O modelo possui histórico e deve ser arquivado.");
      }
      const versions = await tx
        .select({ id: templateVersions.id })
        .from(templateVersions)
        .where(eq(templateVersions.templateId, templateId));
      await tx.insert(syncChangeLog).values({
        organizationId: context.organizationId,
        entityType: "TEMPLATE",
        entityId: templateId,
        revision: 1,
        changeType: "DELETE",
        payload: { id: templateId },
      });
      for (const version of versions) {
        await tx.delete(templateItems).where(eq(templateItems.versionId, version.id));
        await tx.delete(templateSections).where(eq(templateSections.versionId, version.id));
      }
      await tx
        .delete(assetTemplateAssignments)
        .where(eq(assetTemplateAssignments.templateId, templateId));
      await tx.delete(operationConfigs).where(eq(operationConfigs.templateId, templateId));
      await tx.delete(templateVersions).where(eq(templateVersions.templateId, templateId));
      const deleted = await tx
        .delete(checklistTemplates)
        .where(
          and(
            eq(checklistTemplates.id, templateId),
            eq(checklistTemplates.organizationId, context.organizationId),
          ),
        )
        .returning({ id: checklistTemplates.id });
      if (!deleted.length) throw notFound("Modelo não encontrado.");
    });
  }

  private async writeSections(
    tx: Parameters<Parameters<typeof this.database.transaction>[0]>[0],
    versionId: string,
    sections: CreateTemplateInput["sections"] | UpdateTemplateVersionInput["sections"],
  ) {
    let itemOrder = 0;
    for (const [sectionOrder, section] of sections.entries()) {
      const sectionId = section.id ?? randomUUID();
      await tx
        .insert(templateSections)
        .values({ id: sectionId, versionId, title: section.title, sortOrder: sectionOrder });
      await tx.insert(templateItems).values(
        section.items.map((item) => ({
          id: item.id ?? randomUUID(),
          sectionId,
          versionId,
          sourcePrintedNumber: item.sourcePrintedNumber,
          originalText: item.text,
          sortOrder: itemOrder++,
          requiredOnComplete: item.requiredOnComplete,
          requireObservationWhenNc: item.requireObservationWhenNc,
          requirePhotoWhenNc: item.requirePhotoWhenNc,
        })),
      );
    }
  }
}
