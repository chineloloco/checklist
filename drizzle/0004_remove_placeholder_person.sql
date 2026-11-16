UPDATE "people"
SET "active" = false,
    "updated_at" = now()
WHERE "name" = 'Responsável pelo preenchimento'
  AND "user_id" IS NOT NULL;

UPDATE "users"
SET "display_name" = 'Inspetor',
    "updated_at" = now()
WHERE "display_name" = 'Responsável pelo preenchimento';
