INSERT INTO "operation_configs" (
  "organization_id",
  "template_id",
  "timezone",
  "week_starts_on",
  "max_occurrences_per_date",
  "effective_from"
)
SELECT
  template."organization_id",
  template."id",
  organization."timezone",
  organization."week_starts_on",
  1,
  DATE '2020-01-01'
FROM "checklist_templates" AS template
INNER JOIN "organizations" AS organization
  ON organization."id" = template."organization_id"
WHERE template."status" = 'ACTIVE'
  AND EXISTS (
    SELECT 1
    FROM "template_versions" AS version
    WHERE version."template_id" = template."id"
      AND version."status" = 'PUBLISHED'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM "operation_configs" AS config
    WHERE config."organization_id" = template."organization_id"
      AND config."template_id" = template."id"
      AND config."active" = true
  );
