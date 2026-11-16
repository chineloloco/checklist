CREATE TABLE "mobile_auth_sessions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"family_id" uuid NOT NULL,
	"user_id" uuid NOT NULL,
	"organization_id" uuid NOT NULL,
	"refresh_token_hash" varchar(64) NOT NULL,
	"device_id" varchar(100),
	"expires_at" timestamp with time zone NOT NULL,
	"last_used_at" timestamp with time zone,
	"revoked_at" timestamp with time zone,
	"replaced_by_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "mobile_auth_sessions" ADD CONSTRAINT "mobile_auth_sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mobile_auth_sessions" ADD CONSTRAINT "mobile_auth_sessions_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mobile_auth_sessions" ADD CONSTRAINT "mobile_auth_sessions_replaced_by_id_mobile_auth_sessions_id_fk" FOREIGN KEY ("replaced_by_id") REFERENCES "public"."mobile_auth_sessions"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "mobile_auth_sessions_refresh_hash_uq" ON "mobile_auth_sessions" USING btree ("refresh_token_hash");--> statement-breakpoint
CREATE INDEX "mobile_auth_sessions_user_idx" ON "mobile_auth_sessions" USING btree ("user_id","expires_at");--> statement-breakpoint
CREATE INDEX "mobile_auth_sessions_family_idx" ON "mobile_auth_sessions" USING btree ("family_id");