ALTER TABLE "users" ADD COLUMN "employee_number" varchar(50);
--> statement-breakpoint
ALTER TABLE "users" ALTER COLUMN "email" DROP NOT NULL;
--> statement-breakpoint
CREATE UNIQUE INDEX "users_employee_number_uq" ON "users" (upper(trim("employee_number")));
