CREATE TYPE "public"."asset_kind" AS ENUM('VEHICLE', 'EQUIPMENT');--> statement-breakpoint
CREATE TYPE "public"."conflict_resolution" AS ENUM('CHOOSE_PRIMARY', 'KEEP_SEPARATE', 'MERGE');--> statement-breakpoint
CREATE TYPE "public"."conflict_status" AS ENUM('OPEN', 'RESOLVED');--> statement-breakpoint
CREATE TYPE "public"."conflict_type" AS ENUM('DUPLICATE_SLOT', 'REVISION_CONFLICT');--> statement-breakpoint
CREATE TYPE "public"."inspection_lifecycle_status" AS ENUM('DRAFT', 'COMPLETED', 'CORRECTED', 'VOIDED');--> statement-breakpoint
CREATE TYPE "public"."ownership_type" AS ENUM('OWN', 'THIRD_PARTY');--> statement-breakpoint
CREATE TYPE "public"."response_result" AS ENUM('C', 'NC', 'NA');--> statement-breakpoint
CREATE TYPE "public"."template_status" AS ENUM('DRAFT', 'ACTIVE', 'ARCHIVED');--> statement-breakpoint
CREATE TYPE "public"."user_role" AS ENUM('ORG_ADMIN', 'TEMPLATE_MANAGER', 'FLEET_MANAGER', 'SUPERVISOR', 'INSPECTOR', 'AUDITOR');--> statement-breakpoint
CREATE TYPE "public"."template_version_status" AS ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED');--> statement-breakpoint
CREATE TABLE "asset_revisions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"asset_id" uuid NOT NULL,
	"revision" integer NOT NULL,
	"snapshot" jsonb NOT NULL,
	"changed_by" uuid,
	"changed_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "asset_template_assignments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"asset_id" uuid NOT NULL,
	"template_id" uuid NOT NULL,
	"operation_config_id" uuid NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "assets" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"company_id" uuid NOT NULL,
	"site_id" uuid,
	"kind" "asset_kind" NOT NULL,
	"code" varchar(100) NOT NULL,
	"license_plate" varchar(20),
	"make_model" varchar(200),
	"manufacturer" varchar(200),
	"manufacture_year" integer,
	"predominant_color" varchar(80),
	"ownership_type" "ownership_type" NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"revision" integer DEFAULT 1 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "audit_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"entity_type" varchar(60) NOT NULL,
	"entity_id" uuid NOT NULL,
	"action" varchar(80) NOT NULL,
	"actor_user_id" uuid,
	"reason" text,
	"changes" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"occurred_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "checklist_templates" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"code" varchar(40) NOT NULL,
	"name" varchar(200),
	"asset_kind" "asset_kind" NOT NULL,
	"status" "template_status" DEFAULT 'DRAFT' NOT NULL,
	"identification_status" varchar(40) DEFAULT 'CONFIRMED' NOT NULL,
	"archived_at" timestamp with time zone,
	"archived_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "companies" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"name" varchar(200) NOT NULL,
	"document" varchar(30),
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "conflict_cases" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"type" "conflict_type" NOT NULL,
	"status" "conflict_status" DEFAULT 'OPEN' NOT NULL,
	"revision" integer DEFAULT 1 NOT NULL,
	"resolution" "conflict_resolution",
	"reason" text,
	"resolved_by" uuid,
	"resolved_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "conflict_members" (
	"conflict_id" uuid NOT NULL,
	"inspection_id" uuid NOT NULL,
	"role" varchar(30) NOT NULL,
	CONSTRAINT "conflict_members_conflict_id_inspection_id_pk" PRIMARY KEY("conflict_id","inspection_id")
);
--> statement-breakpoint
CREATE TABLE "idempotency_receipts" (
	"organization_id" uuid NOT NULL,
	"device_id" varchar(100) NOT NULL,
	"operation_id" uuid NOT NULL,
	"request_hash" varchar(100) NOT NULL,
	"status_code" integer NOT NULL,
	"response_body" jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "idempotency_receipts_organization_id_device_id_operation_id_pk" PRIMARY KEY("organization_id","device_id","operation_id")
);
--> statement-breakpoint
CREATE TABLE "inspection_revisions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"inspection_id" uuid NOT NULL,
	"revision_number" integer NOT NULL,
	"lifecycle_status" "inspection_lifecycle_status" NOT NULL,
	"identification_snapshot" jsonb NOT NULL,
	"observations" text,
	"correction_reason" text,
	"changes" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"authored_by" uuid,
	"authored_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "inspection_slots" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"weekly_checklist_id" uuid NOT NULL,
	"local_date" date NOT NULL,
	"occurrence_no" integer DEFAULT 1 NOT NULL,
	"expected" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "inspection_slots_occurrence_ck" CHECK ("inspection_slots"."occurrence_no" >= 1)
);
--> statement-breakpoint
CREATE TABLE "inspections" (
	"id" uuid PRIMARY KEY NOT NULL,
	"organization_id" uuid NOT NULL,
	"weekly_checklist_id" uuid NOT NULL,
	"slot_id" uuid NOT NULL,
	"client_inspection_id" uuid NOT NULL,
	"device_id" varchar(100) NOT NULL,
	"lifecycle_status" "inspection_lifecycle_status" DEFAULT 'DRAFT' NOT NULL,
	"current_revision" integer DEFAULT 1 NOT NULL,
	"is_conflict_candidate" boolean DEFAULT false NOT NULL,
	"responsible_person_id" uuid,
	"created_by" uuid,
	"completed_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "operation_configs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"template_id" uuid NOT NULL,
	"site_id" uuid,
	"timezone" varchar(80) NOT NULL,
	"week_starts_on" varchar(16) DEFAULT 'MONDAY' NOT NULL,
	"max_occurrences_per_date" integer DEFAULT 1 NOT NULL,
	"effective_from" date NOT NULL,
	"effective_to" date,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "operation_configs_occurrence_ck" CHECK ("operation_configs"."max_occurrences_per_date" >= 1)
);
--> statement-breakpoint
CREATE TABLE "operation_required_days" (
	"operation_config_id" uuid NOT NULL,
	"weekday" integer NOT NULL,
	"minimum_occurrences" integer DEFAULT 1 NOT NULL,
	CONSTRAINT "operation_required_days_operation_config_id_weekday_pk" PRIMARY KEY("operation_config_id","weekday"),
	CONSTRAINT "operation_required_days_weekday_ck" CHECK ("operation_required_days"."weekday" between 1 and 7),
	CONSTRAINT "operation_required_days_min_ck" CHECK ("operation_required_days"."minimum_occurrences" >= 1)
);
--> statement-breakpoint
CREATE TABLE "organizations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar(200) NOT NULL,
	"timezone" varchar(80) DEFAULT 'America/Fortaleza' NOT NULL,
	"week_starts_on" varchar(16) DEFAULT 'MONDAY' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "people" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"user_id" uuid,
	"name" varchar(200) NOT NULL,
	"kind" varchar(30) NOT NULL,
	"driver_license_number" varchar(30),
	"driver_license_expiry_date" date,
	"mopp_expiry_date" date,
	"passenger_course_expiry_date" date,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "responses" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"inspection_revision_id" uuid NOT NULL,
	"template_item_id" uuid NOT NULL,
	"result" "response_result",
	"observation" text
);
--> statement-breakpoint
CREATE TABLE "signatures" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"inspection_id" uuid,
	"weekly_checklist_id" uuid,
	"role" varchar(40) NOT NULL,
	"signer_name" varchar(200) NOT NULL,
	"method" varchar(30) NOT NULL,
	"object_key" text,
	"checksum" varchar(100),
	"signed_at" timestamp with time zone DEFAULT now() NOT NULL,
	"metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
	CONSTRAINT "signatures_single_scope_ck" CHECK (("signatures"."inspection_id" is not null and "signatures"."weekly_checklist_id" is null) or ("signatures"."inspection_id" is null and "signatures"."weekly_checklist_id" is not null))
);
--> statement-breakpoint
CREATE TABLE "sites" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"company_id" uuid NOT NULL,
	"name" varchar(200) NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sync_change_log" (
	"sequence" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "sync_change_log_sequence_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1),
	"organization_id" uuid NOT NULL,
	"entity_type" varchar(60) NOT NULL,
	"entity_id" uuid NOT NULL,
	"revision" integer NOT NULL,
	"change_type" varchar(20) NOT NULL,
	"payload" jsonb,
	"changed_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "template_items" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"section_id" uuid NOT NULL,
	"version_id" uuid NOT NULL,
	"source_printed_number" varchar(20),
	"original_text" text NOT NULL,
	"sort_order" integer NOT NULL,
	"required_on_complete" boolean DEFAULT true NOT NULL,
	"require_observation_when_nc" boolean DEFAULT false NOT NULL,
	"require_photo_when_nc" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "template_sections" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"version_id" uuid NOT NULL,
	"title" varchar(300) NOT NULL,
	"sort_order" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "template_versions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"template_id" uuid NOT NULL,
	"version_number" integer NOT NULL,
	"status" "template_version_status" DEFAULT 'DRAFT' NOT NULL,
	"revision" integer DEFAULT 1 NOT NULL,
	"checksum" varchar(100),
	"identification_fields" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"published_at" timestamp with time zone,
	"published_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"email" varchar(320) NOT NULL,
	"display_name" varchar(200) NOT NULL,
	"password_hash" text,
	"external_subject" varchar(300),
	"roles" "user_role"[] NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"last_login_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "weekly_checklists" (
	"id" uuid PRIMARY KEY NOT NULL,
	"organization_id" uuid NOT NULL,
	"asset_id" uuid NOT NULL,
	"template_id" uuid NOT NULL,
	"template_version_id" uuid NOT NULL,
	"operation_config_id" uuid NOT NULL,
	"week_start_date" date NOT NULL,
	"timezone" varchar(80) NOT NULL,
	"revision" integer DEFAULT 1 NOT NULL,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "asset_revisions" ADD CONSTRAINT "asset_revisions_asset_id_assets_id_fk" FOREIGN KEY ("asset_id") REFERENCES "public"."assets"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "asset_revisions" ADD CONSTRAINT "asset_revisions_changed_by_users_id_fk" FOREIGN KEY ("changed_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "asset_template_assignments" ADD CONSTRAINT "asset_template_assignments_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "asset_template_assignments" ADD CONSTRAINT "asset_template_assignments_asset_id_assets_id_fk" FOREIGN KEY ("asset_id") REFERENCES "public"."assets"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "asset_template_assignments" ADD CONSTRAINT "asset_template_assignments_template_id_checklist_templates_id_fk" FOREIGN KEY ("template_id") REFERENCES "public"."checklist_templates"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "asset_template_assignments" ADD CONSTRAINT "asset_template_assignments_operation_config_id_operation_configs_id_fk" FOREIGN KEY ("operation_config_id") REFERENCES "public"."operation_configs"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "assets" ADD CONSTRAINT "assets_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "assets" ADD CONSTRAINT "assets_company_id_companies_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "assets" ADD CONSTRAINT "assets_site_id_sites_id_fk" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_actor_user_id_users_id_fk" FOREIGN KEY ("actor_user_id") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "checklist_templates" ADD CONSTRAINT "checklist_templates_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "checklist_templates" ADD CONSTRAINT "checklist_templates_archived_by_users_id_fk" FOREIGN KEY ("archived_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "companies" ADD CONSTRAINT "companies_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "conflict_cases" ADD CONSTRAINT "conflict_cases_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "conflict_cases" ADD CONSTRAINT "conflict_cases_resolved_by_users_id_fk" FOREIGN KEY ("resolved_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "conflict_members" ADD CONSTRAINT "conflict_members_conflict_id_conflict_cases_id_fk" FOREIGN KEY ("conflict_id") REFERENCES "public"."conflict_cases"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "conflict_members" ADD CONSTRAINT "conflict_members_inspection_id_inspections_id_fk" FOREIGN KEY ("inspection_id") REFERENCES "public"."inspections"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "idempotency_receipts" ADD CONSTRAINT "idempotency_receipts_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspection_revisions" ADD CONSTRAINT "inspection_revisions_inspection_id_inspections_id_fk" FOREIGN KEY ("inspection_id") REFERENCES "public"."inspections"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspection_revisions" ADD CONSTRAINT "inspection_revisions_authored_by_users_id_fk" FOREIGN KEY ("authored_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspection_slots" ADD CONSTRAINT "inspection_slots_weekly_checklist_id_weekly_checklists_id_fk" FOREIGN KEY ("weekly_checklist_id") REFERENCES "public"."weekly_checklists"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspections" ADD CONSTRAINT "inspections_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspections" ADD CONSTRAINT "inspections_weekly_checklist_id_weekly_checklists_id_fk" FOREIGN KEY ("weekly_checklist_id") REFERENCES "public"."weekly_checklists"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspections" ADD CONSTRAINT "inspections_slot_id_inspection_slots_id_fk" FOREIGN KEY ("slot_id") REFERENCES "public"."inspection_slots"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspections" ADD CONSTRAINT "inspections_responsible_person_id_people_id_fk" FOREIGN KEY ("responsible_person_id") REFERENCES "public"."people"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspections" ADD CONSTRAINT "inspections_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "operation_configs" ADD CONSTRAINT "operation_configs_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "operation_configs" ADD CONSTRAINT "operation_configs_template_id_checklist_templates_id_fk" FOREIGN KEY ("template_id") REFERENCES "public"."checklist_templates"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "operation_configs" ADD CONSTRAINT "operation_configs_site_id_sites_id_fk" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "operation_required_days" ADD CONSTRAINT "operation_required_days_operation_config_id_operation_configs_id_fk" FOREIGN KEY ("operation_config_id") REFERENCES "public"."operation_configs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "people" ADD CONSTRAINT "people_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "people" ADD CONSTRAINT "people_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "responses" ADD CONSTRAINT "responses_inspection_revision_id_inspection_revisions_id_fk" FOREIGN KEY ("inspection_revision_id") REFERENCES "public"."inspection_revisions"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "responses" ADD CONSTRAINT "responses_template_item_id_template_items_id_fk" FOREIGN KEY ("template_item_id") REFERENCES "public"."template_items"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "signatures" ADD CONSTRAINT "signatures_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "signatures" ADD CONSTRAINT "signatures_inspection_id_inspections_id_fk" FOREIGN KEY ("inspection_id") REFERENCES "public"."inspections"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "signatures" ADD CONSTRAINT "signatures_weekly_checklist_id_weekly_checklists_id_fk" FOREIGN KEY ("weekly_checklist_id") REFERENCES "public"."weekly_checklists"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sites" ADD CONSTRAINT "sites_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sites" ADD CONSTRAINT "sites_company_id_companies_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sync_change_log" ADD CONSTRAINT "sync_change_log_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "template_items" ADD CONSTRAINT "template_items_section_id_template_sections_id_fk" FOREIGN KEY ("section_id") REFERENCES "public"."template_sections"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "template_items" ADD CONSTRAINT "template_items_version_id_template_versions_id_fk" FOREIGN KEY ("version_id") REFERENCES "public"."template_versions"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "template_sections" ADD CONSTRAINT "template_sections_version_id_template_versions_id_fk" FOREIGN KEY ("version_id") REFERENCES "public"."template_versions"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "template_versions" ADD CONSTRAINT "template_versions_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "template_versions" ADD CONSTRAINT "template_versions_template_id_checklist_templates_id_fk" FOREIGN KEY ("template_id") REFERENCES "public"."checklist_templates"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "template_versions" ADD CONSTRAINT "template_versions_published_by_users_id_fk" FOREIGN KEY ("published_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "weekly_checklists" ADD CONSTRAINT "weekly_checklists_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "weekly_checklists" ADD CONSTRAINT "weekly_checklists_asset_id_assets_id_fk" FOREIGN KEY ("asset_id") REFERENCES "public"."assets"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "weekly_checklists" ADD CONSTRAINT "weekly_checklists_template_id_checklist_templates_id_fk" FOREIGN KEY ("template_id") REFERENCES "public"."checklist_templates"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "weekly_checklists" ADD CONSTRAINT "weekly_checklists_template_version_id_template_versions_id_fk" FOREIGN KEY ("template_version_id") REFERENCES "public"."template_versions"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "weekly_checklists" ADD CONSTRAINT "weekly_checklists_operation_config_id_operation_configs_id_fk" FOREIGN KEY ("operation_config_id") REFERENCES "public"."operation_configs"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "weekly_checklists" ADD CONSTRAINT "weekly_checklists_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "asset_revisions_asset_rev_uq" ON "asset_revisions" USING btree ("asset_id","revision");--> statement-breakpoint
CREATE UNIQUE INDEX "asset_template_assignments_uq" ON "asset_template_assignments" USING btree ("asset_id","template_id");--> statement-breakpoint
CREATE UNIQUE INDEX "assets_org_code_uq" ON "assets" USING btree ("organization_id","code");--> statement-breakpoint
CREATE INDEX "assets_org_site_idx" ON "assets" USING btree ("organization_id","site_id");--> statement-breakpoint
CREATE INDEX "audit_events_entity_idx" ON "audit_events" USING btree ("organization_id","entity_type","entity_id","occurred_at");--> statement-breakpoint
CREATE UNIQUE INDEX "templates_org_code_uq" ON "checklist_templates" USING btree ("organization_id","code");--> statement-breakpoint
CREATE UNIQUE INDEX "companies_org_name_uq" ON "companies" USING btree ("organization_id","name");--> statement-breakpoint
CREATE INDEX "conflict_cases_org_status_idx" ON "conflict_cases" USING btree ("organization_id","status");--> statement-breakpoint
CREATE UNIQUE INDEX "inspection_revisions_inspection_rev_uq" ON "inspection_revisions" USING btree ("inspection_id","revision_number");--> statement-breakpoint
CREATE UNIQUE INDEX "inspection_slots_business_uq" ON "inspection_slots" USING btree ("weekly_checklist_id","local_date","occurrence_no");--> statement-breakpoint
CREATE UNIQUE INDEX "inspections_org_client_id_uq" ON "inspections" USING btree ("organization_id","client_inspection_id");--> statement-breakpoint
CREATE INDEX "inspections_weekly_idx" ON "inspections" USING btree ("weekly_checklist_id","slot_id");--> statement-breakpoint
CREATE INDEX "inspections_updated_idx" ON "inspections" USING btree ("organization_id","updated_at","id");--> statement-breakpoint
CREATE INDEX "operation_configs_lookup_idx" ON "operation_configs" USING btree ("organization_id","template_id","site_id","effective_from");--> statement-breakpoint
CREATE INDEX "people_org_kind_idx" ON "people" USING btree ("organization_id","kind");--> statement-breakpoint
CREATE UNIQUE INDEX "responses_revision_item_uq" ON "responses" USING btree ("inspection_revision_id","template_item_id");--> statement-breakpoint
CREATE UNIQUE INDEX "sites_company_name_uq" ON "sites" USING btree ("company_id","name");--> statement-breakpoint
CREATE INDEX "sync_change_log_pull_idx" ON "sync_change_log" USING btree ("organization_id","sequence");--> statement-breakpoint
CREATE UNIQUE INDEX "template_items_version_order_uq" ON "template_items" USING btree ("version_id","sort_order");--> statement-breakpoint
CREATE INDEX "template_items_section_idx" ON "template_items" USING btree ("section_id");--> statement-breakpoint
CREATE UNIQUE INDEX "template_sections_version_order_uq" ON "template_sections" USING btree ("version_id","sort_order");--> statement-breakpoint
CREATE UNIQUE INDEX "template_versions_template_number_uq" ON "template_versions" USING btree ("template_id","version_number");--> statement-breakpoint
CREATE INDEX "template_versions_org_status_idx" ON "template_versions" USING btree ("organization_id","status");--> statement-breakpoint
CREATE UNIQUE INDEX "users_org_email_uq" ON "users" USING btree ("organization_id","email");--> statement-breakpoint
CREATE UNIQUE INDEX "users_external_subject_uq" ON "users" USING btree ("external_subject");--> statement-breakpoint
CREATE UNIQUE INDEX "weekly_checklists_business_uq" ON "weekly_checklists" USING btree ("organization_id","asset_id","template_id","week_start_date");--> statement-breakpoint
CREATE INDEX "weekly_checklists_filter_idx" ON "weekly_checklists" USING btree ("organization_id","week_start_date","asset_id");