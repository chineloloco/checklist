import { and, desc, eq } from "drizzle-orm";
import { getDb } from "@/infrastructure/db/client";
import { auditEvents, users } from "@/infrastructure/db/schema";

export async function listAuditEvents(
  organizationId: string,
  entityType?: string | null,
  entityId?: string | null,
) {
  const filters = [eq(auditEvents.organizationId, organizationId)];
  if (entityType) filters.push(eq(auditEvents.entityType, entityType));
  if (entityId) filters.push(eq(auditEvents.entityId, entityId));
  const rows = await getDb()
    .select({ event: auditEvents, currentActorName: users.displayName })
    .from(auditEvents)
    .leftJoin(
      users,
      and(eq(users.id, auditEvents.actorUserId), eq(users.organizationId, organizationId)),
    )
    .where(and(...filters))
    .orderBy(desc(auditEvents.occurredAt))
    .limit(200);
  return rows.map(({ event, currentActorName }) => ({
    ...event,
    actorDisplayName:
      event.actorDisplayName ??
      currentActorName ??
      (event.actorUserId ? "Autor não disponível" : "Sistema"),
    actorNamePreserved: event.actorDisplayName !== null,
  }));
}
