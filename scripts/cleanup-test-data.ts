import { loadEnvConfig } from "@next/env";
import { createHash } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import postgres from "postgres";

loadEnvConfig(process.cwd());

const organizationId = process.argv[process.argv.indexOf("--organization") + 1];
const execute = process.argv.includes("--execute");
const expectedPlan = process.argv.includes("--expect-plan")
  ? process.argv[process.argv.indexOf("--expect-plan") + 1]
  : undefined;
if (!process.argv.includes("--organization") || !/^[0-9a-f-]{36}$/i.test(organizationId ?? "")) {
  throw new Error("Specify --organization UUID. The default action is a dry run.");
}
const connection = process.env.DATABASE_DIRECT_URL ?? process.env.DATABASE_URL;
if (!connection) throw new Error("Database connection not configured.");
const db = postgres(connection, { max: 1, prepare: false, ssl: "require", connect_timeout: 10 });
const digest = (value: unknown) => createHash("sha256").update(JSON.stringify(value)).digest("hex");

async function main() {
  await db.begin(async (tx) => {
    // This maintenance script operates on one explicitly named organization.
    // Locks prevent concurrent changes between the backup and deletion.
    if (execute) {
      await tx.unsafe(`LOCK TABLE companies, sites, people, assets, asset_revisions,
        checklist_templates, template_versions, template_sections, template_items,
        operation_configs, operation_required_days, asset_template_assignments,
        weekly_checklists, inspection_slots, inspections, inspection_revisions,
        responses, signatures, conflict_cases, conflict_members, idempotency_receipts,
        sync_change_log, users, audit_events IN SHARE ROW EXCLUSIVE MODE`);
    }
    const [organization] =
      await tx`select id, name from organizations where id = ${organizationId}`;
    if (!organization) throw new Error("Organization not found.");
    const usersBefore =
      await tx`select id, display_name, employee_number, roles, active from users where organization_id = ${organizationId} order by id`;
    const templates =
      await tx`select * from checklist_templates where organization_id = ${organizationId} order by id`;
    const deletedTemplates = templates.filter((row) =>
      String(row.name ?? "")
        .toLowerCase()
        .includes("teste"),
    );
    const keptTemplates = templates.filter((row) => !deletedTemplates.includes(row));
    const deletedIds = deletedTemplates.map((row) => String(row.id));
    const templatesBeforeHash = digest(keptTemplates);

    const queries: Record<string, string> = {
      companies: "select * from companies where organization_id = $1 order by id",
      sites: "select * from sites where organization_id = $1 order by id",
      people: "select * from people where organization_id = $1 order by id",
      assets: "select * from assets where organization_id = $1 order by id",
      asset_revisions:
        "select * from asset_revisions where asset_id in (select id from assets where organization_id = $1) order by id",
      asset_template_assignments:
        "select * from asset_template_assignments where organization_id = $1 order by id",
      weekly_checklists: "select * from weekly_checklists where organization_id = $1 order by id",
      inspection_slots:
        "select * from inspection_slots where weekly_checklist_id in (select id from weekly_checklists where organization_id = $1) order by id",
      inspections: "select * from inspections where organization_id = $1 order by id",
      inspection_revisions:
        "select * from inspection_revisions where inspection_id in (select id from inspections where organization_id = $1) order by id",
      responses:
        "select * from responses where inspection_revision_id in (select r.id from inspection_revisions r join inspections i on i.id = r.inspection_id where i.organization_id = $1) order by id",
      signatures: "select * from signatures where organization_id = $1 order by id",
      conflict_cases: "select * from conflict_cases where organization_id = $1 order by id",
      conflict_members:
        "select * from conflict_members where conflict_id in (select id from conflict_cases where organization_id = $1) order by conflict_id, inspection_id",
      idempotency_receipts:
        "select * from idempotency_receipts where organization_id = $1 order by device_id, operation_id",
      sync_change_log: "select * from sync_change_log where organization_id = $1 order by sequence",
      template_versions: "select * from template_versions where organization_id = $1 order by id",
      template_sections:
        "select * from template_sections where version_id in (select id from template_versions where organization_id = $1) order by id",
      template_items:
        "select * from template_items where version_id in (select id from template_versions where organization_id = $1) order by id",
      operation_configs: "select * from operation_configs where organization_id = $1 order by id",
      operation_required_days:
        "select * from operation_required_days where operation_config_id in (select id from operation_configs where organization_id = $1) order by operation_config_id, weekday",
    };
    const rows: Record<string, postgres.Row[]> = {};
    for (const [table, query] of Object.entries(queries))
      rows[table] = await tx.unsafe(query, [organizationId]);
    const versionsToDelete = rows.template_versions.filter((row) =>
      deletedIds.includes(row.template_id),
    );
    const versionIds = versionsToDelete.map((row) => row.id);
    const configsToDelete = rows.operation_configs.filter((row) =>
      deletedIds.includes(row.template_id),
    );
    const configIds = configsToDelete.map((row) => row.id);
    const deletedSiteIds = rows.sites.map((row) => row.id);
    const protectedRows = {
      template_versions: rows.template_versions.filter((row) => !versionIds.includes(row.id)),
      template_sections: rows.template_sections.filter(
        (row) => !versionIds.includes(row.version_id),
      ),
      template_items: rows.template_items.filter((row) => !versionIds.includes(row.version_id)),
      operation_configs: rows.operation_configs
        .filter((row) => !configIds.includes(row.id))
        .map((row) => ({
          ...row,
          site_id: deletedSiteIds.includes(row.site_id) ? null : row.site_id,
        })),
      operation_required_days: rows.operation_required_days.filter(
        (row) => !configIds.includes(row.operation_config_id),
      ),
    };
    const removed: Record<string, postgres.Row[]> = {
      ...rows,
      checklist_templates: deletedTemplates,
      template_versions: versionsToDelete,
      template_sections: rows.template_sections.filter((row) =>
        versionIds.includes(row.version_id),
      ),
      template_items: rows.template_items.filter((row) => versionIds.includes(row.version_id)),
      operation_configs: configsToDelete,
      operation_required_days: rows.operation_required_days.filter((row) =>
        configIds.includes(row.operation_config_id),
      ),
    };
    const plan = {
      organization,
      removed: Object.fromEntries(
        Object.entries(removed).map(([table, data]) => [table, data.length]),
      ),
      removedTemplates: deletedTemplates.map(({ id, code, name }) => ({ id, code, name })),
      keptTemplates: keptTemplates.map(({ id, code, name }) => ({ id, code, name })),
      keptUsers: usersBefore.length,
    };
    const planHash = digest({
      plan,
      rowHashes: Object.fromEntries(
        Object.entries(rows).map(([table, data]) => [table, digest(data)]),
      ),
    });
    console.log(
      JSON.stringify({ mode: execute ? "execute" : "dry-run", planHash, ...plan }, null, 2),
    );
    if (!execute) return;
    if (expectedPlan !== planHash)
      throw new Error("Plan changed or --expect-plan missing. Run the dry run again.");

    const backupDir = path.resolve(process.cwd(), ".local-backups");
    await mkdir(backupDir, { recursive: true });
    const backupPath = path.join(
      backupDir,
      `test-data-${organizationId}-${new Date().toISOString().replaceAll(":", "-")}.json`,
    );
    const backup = JSON.stringify(
      {
        createdAt: new Date().toISOString(),
        planHash,
        plan,
        rows: { ...rows, checklist_templates: templates },
      },
      null,
      2,
    );
    await writeFile(backupPath, backup, { flag: "wx" });
    console.log(JSON.stringify({ backupPath, backupSha256: digest(backup) }));

    const deleteOrder = [
      "conflict_members",
      "conflict_cases",
      "signatures",
      "responses",
      "inspection_revisions",
      "inspections",
      "inspection_slots",
      "weekly_checklists",
      "asset_template_assignments",
      "asset_revisions",
      "assets",
      "people",
    ];
    for (const table of deleteOrder) {
      const query = queries[table]
        .replace(/^select \* from/, "delete from")
        .replace(/ order by .+$/, "");
      await tx.unsafe(query, [organizationId]);
    }
    await tx`update operation_configs set site_id = null where organization_id = ${organizationId} and site_id in (select id from sites where organization_id = ${organizationId})`;
    await tx`delete from sites where organization_id = ${organizationId}`;
    await tx`delete from companies where organization_id = ${organizationId}`;
    if (deletedIds.length) {
      await tx`delete from template_items where version_id in (select id from template_versions where organization_id = ${organizationId} and template_id in ${tx(deletedIds)})`;
      await tx`delete from template_sections where version_id in (select id from template_versions where organization_id = ${organizationId} and template_id in ${tx(deletedIds)})`;
      await tx`delete from template_versions where organization_id = ${organizationId} and template_id in ${tx(deletedIds)}`;
      await tx`delete from operation_required_days where operation_config_id in (select id from operation_configs where organization_id = ${organizationId} and template_id in ${tx(deletedIds)})`;
      await tx`delete from operation_configs where organization_id = ${organizationId} and template_id in ${tx(deletedIds)}`;
      await tx`delete from checklist_templates where organization_id = ${organizationId} and id in ${tx(deletedIds)}`;
    }
    await tx`delete from idempotency_receipts where organization_id = ${organizationId}`;
    await tx`delete from sync_change_log where organization_id = ${organizationId}`;
    const entityTypes: Record<string, string> = {
      companies: "COMPANY",
      sites: "SITE",
      people: "PERSON",
      assets: "ASSET",
      weekly_checklists: "WEEKLY_CHECKLIST",
      inspections: "INSPECTION",
      checklist_templates: "TEMPLATE",
      template_versions: "TEMPLATE_VERSION",
      operation_configs: "OPERATION_CONFIG",
      asset_template_assignments: "ASSET_TEMPLATE_ASSIGNMENT",
    };
    for (const [table, entityType] of Object.entries(entityTypes)) {
      for (const row of removed[table]) {
        await tx`insert into sync_change_log (organization_id, entity_type, entity_id, revision, change_type, payload) values (${organizationId}, ${entityType}, ${row.id}, ${Number(row.revision ?? row.current_revision ?? 1) + 1}, 'DELETE', ${tx.json({ reason: "TEST_DATA_CLEANUP" })})`;
      }
    }
    const usersAfter =
      await tx`select id, display_name, employee_number, roles, active from users where organization_id = ${organizationId} order by id`;
    const templatesAfter =
      await tx`select * from checklist_templates where organization_id = ${organizationId} order by id`;
    if (
      digest(usersAfter) !== digest(usersBefore) ||
      digest(templatesAfter) !== templatesBeforeHash
    )
      throw new Error("Preservation checks failed; rollback required.");
    for (const [table, expected] of Object.entries(protectedRows)) {
      const actual = await tx.unsafe(queries[table], [organizationId]);
      if (digest(actual) !== digest(expected)) {
        throw new Error(`Preserved model content changed: ${table}; rollback required.`);
      }
    }
    for (const table of [...deleteOrder, "sites", "companies"]) {
      if ((await tx.unsafe(queries[table], [organizationId])).length)
        throw new Error(`Cleanup incomplete: ${table}`);
    }
    await tx`insert into audit_events (organization_id, entity_type, entity_id, action, reason, metadata) values (${organizationId}, 'ORGANIZATION', ${organizationId}, 'TEST_DATA_CLEANED', 'Limpeza definitiva de dados de teste solicitada pelo usuário; modelos sem teste no nome e contas preservados.', ${tx.json({ source: "LOCAL_MAINTENANCE", planHash, removed: plan.removed, backupSha256: digest(backup) })})`;
    console.log("Cleanup checks passed; transaction ready to commit.");
  });
}

main()
  .catch((error) => {
    console.error(JSON.stringify({ error: error.message, code: error.code }));
    process.exitCode = 1;
  })
  .finally(() => db.end());
