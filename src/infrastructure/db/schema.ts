import { sql } from "drizzle-orm";
import {
  type AnyPgColumn,
  bigint,
  boolean,
  check,
  date,
  index,
  integer,
  jsonb,
  pgEnum,
  pgTable,
  primaryKey,
  text,
  timestamp,
  uniqueIndex,
  uuid,
  varchar,
} from "drizzle-orm/pg-core";

export const assetKindEnum = pgEnum("asset_kind", ["VEHICLE", "EQUIPMENT"]);
export const ownershipTypeEnum = pgEnum("ownership_type", ["OWN", "THIRD_PARTY"]);
export const userRoleEnum = pgEnum("user_role", [
  "ORG_ADMIN",
  "TEMPLATE_MANAGER",
  "FLEET_MANAGER",
  "SUPERVISOR",
  "INSPECTOR",
  "AUDITOR",
]);
export const templateStatusEnum = pgEnum("template_status", ["DRAFT", "ACTIVE", "ARCHIVED"]);
export const versionStatusEnum = pgEnum("template_version_status", [
  "DRAFT",
  "PUBLISHED",
  "ARCHIVED",
]);
export const lifecycleStatusEnum = pgEnum("inspection_lifecycle_status", [
  "DRAFT",
  "COMPLETED",
  "CORRECTED",
  "VOIDED",
]);
export const responseResultEnum = pgEnum("response_result", ["C", "NC", "NA"]);
export const conflictTypeEnum = pgEnum("conflict_type", ["DUPLICATE_SLOT", "REVISION_CONFLICT"]);
export const conflictStatusEnum = pgEnum("conflict_status", ["OPEN", "RESOLVED"]);
export const conflictResolutionEnum = pgEnum("conflict_resolution", [
  "CHOOSE_PRIMARY",
  "KEEP_SEPARATE",
  "MERGE",
]);

const auditColumns = {
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
};

export const organizations = pgTable("organizations", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: varchar("name", { length: 200 }).notNull(),
  timezone: varchar("timezone", { length: 80 }).notNull().default("America/Fortaleza"),
  weekStartsOn: varchar("week_starts_on", { length: 16 }).notNull().default("MONDAY"),
  ...auditColumns,
});

export const companies = pgTable(
  "companies",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    name: varchar("name", { length: 200 }).notNull(),
    document: varchar("document", { length: 30 }),
    active: boolean("active").notNull().default(true),
    ...auditColumns,
  },
  (table) => [uniqueIndex("companies_org_name_uq").on(table.organizationId, table.name)],
);

export const sites = pgTable(
  "sites",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    companyId: uuid("company_id").references(() => companies.id, { onDelete: "restrict" }),
    name: varchar("name", { length: 200 }).notNull(),
    active: boolean("active").notNull().default(true),
    ...auditColumns,
  },
  (table) => [uniqueIndex("sites_company_name_uq").on(table.companyId, table.name)],
);

export const users = pgTable(
  "users",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    email: varchar("email", { length: 320 }),
    employeeNumber: varchar("employee_number", { length: 50 }),
    displayName: varchar("display_name", { length: 200 }).notNull(),
    passwordHash: text("password_hash"),
    externalSubject: varchar("external_subject", { length: 300 }),
    roles: userRoleEnum("roles").array().notNull(),
    active: boolean("active").notNull().default(true),
    lastLoginAt: timestamp("last_login_at", { withTimezone: true }),
    ...auditColumns,
  },
  (table) => [
    uniqueIndex("users_org_email_uq").on(table.organizationId, table.email),
    uniqueIndex("users_employee_number_uq").on(sql`upper(trim(${table.employeeNumber}))`),
    uniqueIndex("users_external_subject_uq").on(table.externalSubject),
  ],
);

export const mobileAuthSessions = pgTable(
  "mobile_auth_sessions",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    familyId: uuid("family_id").notNull(),
    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "cascade" }),
    refreshTokenHash: varchar("refresh_token_hash", { length: 64 }).notNull(),
    deviceId: varchar("device_id", { length: 100 }),
    expiresAt: timestamp("expires_at", { withTimezone: true }).notNull(),
    lastUsedAt: timestamp("last_used_at", { withTimezone: true }),
    revokedAt: timestamp("revoked_at", { withTimezone: true }),
    replacedById: uuid("replaced_by_id").references((): AnyPgColumn => mobileAuthSessions.id, {
      onDelete: "set null",
    }),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex("mobile_auth_sessions_refresh_hash_uq").on(table.refreshTokenHash),
    index("mobile_auth_sessions_user_idx").on(table.userId, table.expiresAt),
    index("mobile_auth_sessions_family_idx").on(table.familyId),
  ],
);

export const people = pgTable(
  "people",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    userId: uuid("user_id").references(() => users.id, { onDelete: "set null" }),
    name: varchar("name", { length: 200 }).notNull(),
    kind: varchar("kind", { length: 30 }).notNull(),
    driverLicenseNumber: varchar("driver_license_number", { length: 30 }),
    driverLicenseExpiryDate: date("driver_license_expiry_date"),
    moppExpiryDate: date("mopp_expiry_date"),
    passengerCourseExpiryDate: date("passenger_course_expiry_date"),
    active: boolean("active").notNull().default(true),
    ...auditColumns,
  },
  (table) => [index("people_org_kind_idx").on(table.organizationId, table.kind)],
);

export const assets = pgTable(
  "assets",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    companyId: uuid("company_id")
      .notNull()
      .references(() => companies.id, { onDelete: "restrict" }),
    siteId: uuid("site_id").references(() => sites.id, { onDelete: "restrict" }),
    kind: assetKindEnum("kind").notNull(),
    code: varchar("code", { length: 100 }).notNull(),
    licensePlate: varchar("license_plate", { length: 20 }),
    makeModel: varchar("make_model", { length: 200 }),
    manufacturer: varchar("manufacturer", { length: 200 }),
    manufactureYear: integer("manufacture_year"),
    predominantColor: varchar("predominant_color", { length: 80 }),
    ownershipType: ownershipTypeEnum("ownership_type").notNull(),
    active: boolean("active").notNull().default(true),
    revision: integer("revision").notNull().default(1),
    ...auditColumns,
  },
  (table) => [
    uniqueIndex("assets_org_code_uq").on(table.organizationId, table.code),
    index("assets_org_site_idx").on(table.organizationId, table.siteId),
  ],
);

export const assetRevisions = pgTable(
  "asset_revisions",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    assetId: uuid("asset_id")
      .notNull()
      .references(() => assets.id, { onDelete: "restrict" }),
    revision: integer("revision").notNull(),
    snapshot: jsonb("snapshot").$type<Record<string, unknown>>().notNull(),
    changedBy: uuid("changed_by").references(() => users.id, { onDelete: "restrict" }),
    changedAt: timestamp("changed_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [uniqueIndex("asset_revisions_asset_rev_uq").on(table.assetId, table.revision)],
);

export const checklistTemplates = pgTable(
  "checklist_templates",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    code: varchar("code", { length: 40 }).notNull(),
    name: varchar("name", { length: 200 }),
    assetKind: assetKindEnum("asset_kind").notNull(),
    status: templateStatusEnum("status").notNull().default("DRAFT"),
    identificationStatus: varchar("identification_status", { length: 40 })
      .notNull()
      .default("CONFIRMED"),
    archivedAt: timestamp("archived_at", { withTimezone: true }),
    archivedBy: uuid("archived_by").references(() => users.id, { onDelete: "restrict" }),
    ...auditColumns,
  },
  (table) => [uniqueIndex("templates_org_code_uq").on(table.organizationId, table.code)],
);

export const templateVersions = pgTable(
  "template_versions",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    templateId: uuid("template_id")
      .notNull()
      .references(() => checklistTemplates.id, { onDelete: "restrict" }),
    versionNumber: integer("version_number").notNull(),
    status: versionStatusEnum("status").notNull().default("DRAFT"),
    revision: integer("revision").notNull().default(1),
    checksum: varchar("checksum", { length: 100 }),
    identificationFields: jsonb("identification_fields").$type<string[]>().notNull().default([]),
    publishedAt: timestamp("published_at", { withTimezone: true }),
    publishedBy: uuid("published_by").references(() => users.id, { onDelete: "restrict" }),
    ...auditColumns,
  },
  (table) => [
    uniqueIndex("template_versions_template_number_uq").on(table.templateId, table.versionNumber),
    index("template_versions_org_status_idx").on(table.organizationId, table.status),
  ],
);

export const templateSections = pgTable(
  "template_sections",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    versionId: uuid("version_id")
      .notNull()
      .references(() => templateVersions.id, { onDelete: "restrict" }),
    title: varchar("title", { length: 300 }).notNull(),
    sortOrder: integer("sort_order").notNull(),
  },
  (table) => [
    uniqueIndex("template_sections_version_order_uq").on(table.versionId, table.sortOrder),
  ],
);

export const templateItems = pgTable(
  "template_items",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    sectionId: uuid("section_id")
      .notNull()
      .references(() => templateSections.id, { onDelete: "restrict" }),
    versionId: uuid("version_id")
      .notNull()
      .references(() => templateVersions.id, { onDelete: "restrict" }),
    sourcePrintedNumber: varchar("source_printed_number", { length: 20 }),
    originalText: text("original_text").notNull(),
    sortOrder: integer("sort_order").notNull(),
    requiredOnComplete: boolean("required_on_complete").notNull().default(true),
    requireObservationWhenNc: boolean("require_observation_when_nc").notNull().default(false),
    requirePhotoWhenNc: boolean("require_photo_when_nc").notNull().default(false),
  },
  (table) => [
    uniqueIndex("template_items_version_order_uq").on(table.versionId, table.sortOrder),
    index("template_items_section_idx").on(table.sectionId),
  ],
);

export const operationConfigs = pgTable(
  "operation_configs",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    templateId: uuid("template_id")
      .notNull()
      .references(() => checklistTemplates.id, { onDelete: "restrict" }),
    siteId: uuid("site_id").references(() => sites.id, { onDelete: "restrict" }),
    timezone: varchar("timezone", { length: 80 }).notNull(),
    weekStartsOn: varchar("week_starts_on", { length: 16 }).notNull().default("MONDAY"),
    maxOccurrencesPerDate: integer("max_occurrences_per_date").notNull().default(1),
    effectiveFrom: date("effective_from").notNull(),
    effectiveTo: date("effective_to"),
    active: boolean("active").notNull().default(true),
    ...auditColumns,
  },
  (table) => [
    index("operation_configs_lookup_idx").on(
      table.organizationId,
      table.templateId,
      table.siteId,
      table.effectiveFrom,
    ),
    check("operation_configs_occurrence_ck", sql`${table.maxOccurrencesPerDate} >= 1`),
  ],
);

export const operationRequiredDays = pgTable(
  "operation_required_days",
  {
    operationConfigId: uuid("operation_config_id")
      .notNull()
      .references(() => operationConfigs.id, { onDelete: "cascade" }),
    weekday: integer("weekday").notNull(),
    minimumOccurrences: integer("minimum_occurrences").notNull().default(1),
  },
  (table) => [
    primaryKey({ columns: [table.operationConfigId, table.weekday] }),
    check("operation_required_days_weekday_ck", sql`${table.weekday} between 1 and 7`),
    check("operation_required_days_min_ck", sql`${table.minimumOccurrences} >= 1`),
  ],
);

export const assetTemplateAssignments = pgTable(
  "asset_template_assignments",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    assetId: uuid("asset_id")
      .notNull()
      .references(() => assets.id, { onDelete: "restrict" }),
    templateId: uuid("template_id")
      .notNull()
      .references(() => checklistTemplates.id, { onDelete: "restrict" }),
    operationConfigId: uuid("operation_config_id")
      .notNull()
      .references(() => operationConfigs.id, { onDelete: "restrict" }),
    active: boolean("active").notNull().default(true),
    ...auditColumns,
  },
  (table) => [uniqueIndex("asset_template_assignments_uq").on(table.assetId, table.templateId)],
);

export const weeklyChecklists = pgTable(
  "weekly_checklists",
  {
    id: uuid("id").primaryKey(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    assetId: uuid("asset_id")
      .notNull()
      .references(() => assets.id, { onDelete: "restrict" }),
    templateId: uuid("template_id")
      .notNull()
      .references(() => checklistTemplates.id, { onDelete: "restrict" }),
    templateVersionId: uuid("template_version_id")
      .notNull()
      .references(() => templateVersions.id, { onDelete: "restrict" }),
    operationConfigId: uuid("operation_config_id")
      .notNull()
      .references(() => operationConfigs.id, { onDelete: "restrict" }),
    weekStartDate: date("week_start_date").notNull(),
    timezone: varchar("timezone", { length: 80 }).notNull(),
    revision: integer("revision").notNull().default(1),
    createdBy: uuid("created_by").references(() => users.id, { onDelete: "restrict" }),
    ...auditColumns,
  },
  (table) => [
    uniqueIndex("weekly_checklists_business_uq").on(
      table.organizationId,
      table.assetId,
      table.templateId,
      table.weekStartDate,
    ),
    index("weekly_checklists_filter_idx").on(
      table.organizationId,
      table.weekStartDate,
      table.assetId,
    ),
  ],
);

export const inspectionSlots = pgTable(
  "inspection_slots",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    weeklyChecklistId: uuid("weekly_checklist_id")
      .notNull()
      .references(() => weeklyChecklists.id, { onDelete: "restrict" }),
    localDate: date("local_date").notNull(),
    occurrenceNo: integer("occurrence_no").notNull().default(1),
    expected: boolean("expected").notNull().default(false),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex("inspection_slots_business_uq").on(
      table.weeklyChecklistId,
      table.localDate,
      table.occurrenceNo,
    ),
    check("inspection_slots_occurrence_ck", sql`${table.occurrenceNo} >= 1`),
  ],
);

export const inspections = pgTable(
  "inspections",
  {
    id: uuid("id").primaryKey(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    weeklyChecklistId: uuid("weekly_checklist_id")
      .notNull()
      .references(() => weeklyChecklists.id, { onDelete: "restrict" }),
    slotId: uuid("slot_id")
      .notNull()
      .references(() => inspectionSlots.id, { onDelete: "restrict" }),
    clientInspectionId: uuid("client_inspection_id").notNull(),
    deviceId: varchar("device_id", { length: 100 }).notNull(),
    creationHash: varchar("creation_hash", { length: 100 }).notNull(),
    lifecycleStatus: lifecycleStatusEnum("lifecycle_status").notNull().default("DRAFT"),
    currentRevision: integer("current_revision").notNull().default(1),
    isConflictCandidate: boolean("is_conflict_candidate").notNull().default(false),
    responsiblePersonId: uuid("responsible_person_id").references(() => people.id, {
      onDelete: "restrict",
    }),
    createdBy: uuid("created_by").references(() => users.id, { onDelete: "restrict" }),
    completedAt: timestamp("completed_at", { withTimezone: true }),
    ...auditColumns,
  },
  (table) => [
    uniqueIndex("inspections_org_client_id_uq").on(table.organizationId, table.clientInspectionId),
    index("inspections_weekly_idx").on(table.weeklyChecklistId, table.slotId),
    index("inspections_updated_idx").on(table.organizationId, table.updatedAt, table.id),
  ],
);

export const inspectionRevisions = pgTable(
  "inspection_revisions",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    inspectionId: uuid("inspection_id")
      .notNull()
      .references(() => inspections.id, { onDelete: "restrict" }),
    revisionNumber: integer("revision_number").notNull(),
    lifecycleStatus: lifecycleStatusEnum("lifecycle_status").notNull(),
    identificationSnapshot: jsonb("identification_snapshot")
      .$type<Record<string, unknown>>()
      .notNull(),
    observations: text("observations"),
    correctionReason: text("correction_reason"),
    changes: jsonb("changes").$type<unknown[]>().notNull().default([]),
    authoredBy: uuid("authored_by").references(() => users.id, { onDelete: "restrict" }),
    authoredDisplayName: varchar("authored_display_name", { length: 200 }),
    authoredAt: timestamp("authored_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex("inspection_revisions_inspection_rev_uq").on(
      table.inspectionId,
      table.revisionNumber,
    ),
  ],
);

export const responses = pgTable(
  "responses",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    inspectionRevisionId: uuid("inspection_revision_id")
      .notNull()
      .references(() => inspectionRevisions.id, { onDelete: "restrict" }),
    templateItemId: uuid("template_item_id")
      .notNull()
      .references(() => templateItems.id, { onDelete: "restrict" }),
    result: responseResultEnum("result"),
    observation: text("observation"),
  },
  (table) => [
    uniqueIndex("responses_revision_item_uq").on(table.inspectionRevisionId, table.templateItemId),
  ],
);

export const signatures = pgTable(
  "signatures",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    inspectionId: uuid("inspection_id").references(() => inspections.id, { onDelete: "restrict" }),
    weeklyChecklistId: uuid("weekly_checklist_id").references(() => weeklyChecklists.id, {
      onDelete: "restrict",
    }),
    role: varchar("role", { length: 40 }).notNull(),
    signerName: varchar("signer_name", { length: 200 }).notNull(),
    method: varchar("method", { length: 30 }).notNull(),
    objectKey: text("object_key"),
    checksum: varchar("checksum", { length: 100 }),
    signedAt: timestamp("signed_at", { withTimezone: true }).notNull().defaultNow(),
    metadata: jsonb("metadata").$type<Record<string, unknown>>().notNull().default({}),
  },
  (table) => [
    check(
      "signatures_single_scope_ck",
      sql`(${table.inspectionId} is not null and ${table.weeklyChecklistId} is null) or (${table.inspectionId} is null and ${table.weeklyChecklistId} is not null)`,
    ),
  ],
);

export const idempotencyReceipts = pgTable(
  "idempotency_receipts",
  {
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    deviceId: varchar("device_id", { length: 100 }).notNull(),
    operationId: uuid("operation_id").notNull(),
    requestHash: varchar("request_hash", { length: 100 }).notNull(),
    statusCode: integer("status_code").notNull(),
    responseBody: jsonb("response_body").$type<Record<string, unknown>>().notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [primaryKey({ columns: [table.organizationId, table.deviceId, table.operationId] })],
);

export const conflictCases = pgTable(
  "conflict_cases",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    type: conflictTypeEnum("type").notNull(),
    status: conflictStatusEnum("status").notNull().default("OPEN"),
    revision: integer("revision").notNull().default(1),
    resolution: conflictResolutionEnum("resolution"),
    reason: text("reason"),
    resolvedBy: uuid("resolved_by").references(() => users.id, { onDelete: "restrict" }),
    resolvedAt: timestamp("resolved_at", { withTimezone: true }),
    ...auditColumns,
  },
  (table) => [index("conflict_cases_org_status_idx").on(table.organizationId, table.status)],
);

export const conflictMembers = pgTable(
  "conflict_members",
  {
    conflictId: uuid("conflict_id")
      .notNull()
      .references(() => conflictCases.id, { onDelete: "restrict" }),
    inspectionId: uuid("inspection_id")
      .notNull()
      .references(() => inspections.id, { onDelete: "restrict" }),
    role: varchar("role", { length: 30 }).notNull(),
  },
  (table) => [primaryKey({ columns: [table.conflictId, table.inspectionId] })],
);

export const auditEvents = pgTable(
  "audit_events",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    entityType: varchar("entity_type", { length: 60 }).notNull(),
    entityId: uuid("entity_id").notNull(),
    action: varchar("action", { length: 80 }).notNull(),
    actorUserId: uuid("actor_user_id").references(() => users.id, { onDelete: "restrict" }),
    actorDisplayName: varchar("actor_display_name", { length: 200 }),
    reason: text("reason"),
    changes: jsonb("changes").$type<unknown[]>().notNull().default([]),
    metadata: jsonb("metadata").$type<Record<string, unknown>>().notNull().default({}),
    occurredAt: timestamp("occurred_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    index("audit_events_entity_idx").on(
      table.organizationId,
      table.entityType,
      table.entityId,
      table.occurredAt,
    ),
  ],
);

export const syncChangeLog = pgTable(
  "sync_change_log",
  {
    sequence: bigint("sequence", { mode: "number" }).primaryKey().generatedAlwaysAsIdentity(),
    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, { onDelete: "restrict" }),
    entityType: varchar("entity_type", { length: 60 }).notNull(),
    entityId: uuid("entity_id").notNull(),
    revision: integer("revision").notNull(),
    changeType: varchar("change_type", { length: 20 }).notNull(),
    payload: jsonb("payload").$type<Record<string, unknown>>(),
    changedAt: timestamp("changed_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [index("sync_change_log_pull_idx").on(table.organizationId, table.sequence)],
);

export type UserRow = typeof users.$inferSelect;
export type TemplateVersionRow = typeof templateVersions.$inferSelect;
export type InspectionRow = typeof inspections.$inferSelect;
