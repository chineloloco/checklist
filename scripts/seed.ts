import { loadEnvConfig } from "@next/env";
import { hash } from "bcryptjs";
import { createHash, randomUUID } from "node:crypto";
import { and, eq } from "drizzle-orm";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import catalogJson from "../specs/template-catalog.json";
import * as schema from "../src/infrastructure/db/schema";
import {
  assetRevisions,
  assets,
  assetTemplateAssignments,
  checklistTemplates,
  companies,
  operationConfigs,
  operationRequiredDays,
  organizations,
  people,
  sites,
  templateItems,
  templateSections,
  templateVersions,
  users
} from "../src/infrastructure/db/schema";

loadEnvConfig(process.cwd());

type Catalog = {
  templates: Array<{
    code: string;
    name: string | null;
    asset_kind: "VEHICLE" | "EQUIPMENT";
    identification_status: string;
    identification_fields: string[];
    sections: Array<{
      title: string;
      items: Array<{ printed_number: string; text: string }>;
    }>;
  }>;
};

const catalog = catalogJson as Catalog;
const connectionString = process.env.DATABASE_DIRECT_URL ?? process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("Configure DATABASE_DIRECT_URL or DATABASE_URL.");
}

const sqlClient = postgres(connectionString, { max: 1, prepare: false, ssl: "require" });
const database = drizzle(sqlClient, { schema });

async function firstOrCreate<T>(select: () => Promise<T[]>, create: () => Promise<T[]>): Promise<T> {
  const existing = await select();
  if (existing[0]) return existing[0];
  const inserted = await create();
  if (!inserted[0]) throw new Error("Seed insert failed.");
  return inserted[0];
}

async function main() {
const organization = await firstOrCreate(
  () => database.select().from(organizations).where(eq(organizations.name, "Operação Exemplo")).limit(1),
  () =>
    database
      .insert(organizations)
      .values({
        name: "Operação Exemplo",
        timezone: process.env.DEFAULT_TIMEZONE ?? "America/Fortaleza",
        weekStartsOn: "MONDAY"
      })
      .returning()
);

const company = await firstOrCreate(
  () => database.select().from(companies).where(and(eq(companies.organizationId, organization.id), eq(companies.name, "Empresa Exemplo"))).limit(1),
  () => database.insert(companies).values({ organizationId: organization.id, name: "Empresa Exemplo" }).returning()
);
const site = await firstOrCreate(
  () => database.select().from(sites).where(and(eq(sites.companyId, company.id), eq(sites.name, "Pátio Norte"))).limit(1),
  () => database.insert(sites).values({ organizationId: organization.id, companyId: company.id, name: "Pátio Norte" }).returning()
);

const adminEmail = (process.env.SEED_ADMIN_EMAIL ?? "admin@checklist.local").toLowerCase();
const inspectorEmail = (process.env.SEED_INSPECTOR_EMAIL ?? "responsavel@checklist.local").toLowerCase();
const admin = await firstOrCreate(
  () => database.select().from(users).where(and(eq(users.organizationId, organization.id), eq(users.email, adminEmail))).limit(1),
  async () =>
    database
      .insert(users)
      .values({
        organizationId: organization.id,
        email: adminEmail,
        displayName: "Administrador",
        passwordHash: await hash(process.env.SEED_ADMIN_PASSWORD ?? "ChangeMe-Admin-123!", 12),
        roles: ["ORG_ADMIN"]
      })
      .returning()
);
const inspector = await firstOrCreate(
  () => database.select().from(users).where(and(eq(users.organizationId, organization.id), eq(users.email, inspectorEmail))).limit(1),
  async () =>
    database
      .insert(users)
      .values({
        organizationId: organization.id,
        email: inspectorEmail,
        displayName: "Responsável pelo preenchimento",
        passwordHash: await hash(process.env.SEED_INSPECTOR_PASSWORD ?? "ChangeMe-Responsavel-123!", 12),
        roles: ["INSPECTOR"]
      })
      .returning()
);

const responsible = await firstOrCreate(
  () => database.select().from(people).where(and(eq(people.organizationId, organization.id), eq(people.userId, inspector.id))).limit(1),
  () =>
    database
      .insert(people)
      .values({
        organizationId: organization.id,
        userId: inspector.id,
        name: "Responsável pelo preenchimento",
        kind: "DRIVER",
        driverLicenseNumber: "00000000000",
        driverLicenseExpiryDate: "2028-05-20"
      })
      .returning()
);

let publishedVl: { templateId: string; versionId: string } | null = null;
for (const model of catalog.templates) {
  const existing = await database
    .select()
    .from(checklistTemplates)
    .where(and(eq(checklistTemplates.organizationId, organization.id), eq(checklistTemplates.code, model.code)))
    .limit(1);
  if (existing[0]) {
    const [version] = await database
      .select()
      .from(templateVersions)
      .where(eq(templateVersions.templateId, existing[0].id))
      .limit(1);
    if (model.code === "VL" && version) publishedVl = { templateId: existing[0].id, versionId: version.id };
    continue;
  }

  await database.transaction(async (tx) => {
    const isVl = model.code === "VL";
    const [template] = await tx
      .insert(checklistTemplates)
      .values({
        organizationId: organization.id,
        code: model.code,
        name: model.name,
        assetKind: model.asset_kind,
        status: isVl ? "ACTIVE" : "DRAFT",
        identificationStatus: model.identification_status
      })
      .returning();
    const checksum = `sha256:${createHash("sha256").update(JSON.stringify(model.sections)).digest("hex")}`;
    const [version] = await tx
      .insert(templateVersions)
      .values({
        organizationId: organization.id,
        templateId: template.id,
        versionNumber: 1,
        status: isVl ? "PUBLISHED" : "DRAFT",
        revision: 1,
        checksum: isVl ? checksum : null,
        identificationFields: model.identification_fields,
        publishedAt: isVl ? new Date() : null,
        publishedBy: isVl ? admin.id : null
      })
      .returning();
    let itemOrder = 0;
    for (const [sectionOrder, section] of model.sections.entries()) {
      const sectionId = randomUUID();
      await tx.insert(templateSections).values({ id: sectionId, versionId: version.id, title: section.title, sortOrder: sectionOrder });
      await tx.insert(templateItems).values(
        section.items.map((item) => ({
          id: randomUUID(),
          sectionId,
          versionId: version.id,
          sourcePrintedNumber: item.printed_number,
          originalText: item.text,
          sortOrder: itemOrder++,
          requiredOnComplete: true,
          requireObservationWhenNc: false,
          requirePhotoWhenNc: false
        }))
      );
    }
    if (isVl) publishedVl = { templateId: template.id, versionId: version.id };
  });
}

if (!publishedVl) throw new Error("Published VL template was not created.");

const asset = await firstOrCreate(
  () => database.select().from(assets).where(and(eq(assets.organizationId, organization.id), eq(assets.code, "VL-017"))).limit(1),
  () =>
    database
      .insert(assets)
      .values({
        organizationId: organization.id,
        companyId: company.id,
        siteId: site.id,
        kind: "VEHICLE",
        code: "VL-017",
        licensePlate: "ABC1D23",
        makeModel: "Veículo leve de demonstração",
        manufactureYear: 2022,
        predominantColor: "Branco",
        ownershipType: "OWN"
      })
      .returning()
);
const [assetRevision] = await database.select().from(assetRevisions).where(eq(assetRevisions.assetId, asset.id)).limit(1);
if (!assetRevision) await database.insert(assetRevisions).values({ assetId: asset.id, revision: 1, snapshot: asset, changedBy: admin.id });

const config = await firstOrCreate(
  () => database.select().from(operationConfigs).where(and(eq(operationConfigs.organizationId, organization.id), eq(operationConfigs.templateId, publishedVl!.templateId))).limit(1),
  () =>
    database
      .insert(operationConfigs)
      .values({
        organizationId: organization.id,
        templateId: publishedVl!.templateId,
        siteId: site.id,
        timezone: process.env.DEFAULT_TIMEZONE ?? "America/Fortaleza",
        weekStartsOn: "MONDAY",
        maxOccurrencesPerDate: 1,
        effectiveFrom: "2020-01-01"
      })
      .returning()
);
const requiredDays = await database.select().from(operationRequiredDays).where(eq(operationRequiredDays.operationConfigId, config.id));
if (!requiredDays.length) {
  await database.insert(operationRequiredDays).values([
    { operationConfigId: config.id, weekday: 1, minimumOccurrences: 1 },
    { operationConfigId: config.id, weekday: 3, minimumOccurrences: 1 },
    { operationConfigId: config.id, weekday: 5, minimumOccurrences: 1 }
  ]);
}
await database
  .insert(assetTemplateAssignments)
  .values({ organizationId: organization.id, assetId: asset.id, templateId: publishedVl.templateId, operationConfigId: config.id })
  .onConflictDoUpdate({
    target: [assetTemplateAssignments.assetId, assetTemplateAssignments.templateId],
    set: { operationConfigId: config.id, active: true, updatedAt: new Date() }
  });

console.log(`Seed complete: organization=${organization.id} VL=${publishedVl.templateId} asset=${asset.id} responsible=${responsible.id}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}).finally(async () => {
  await sqlClient.end();
});
