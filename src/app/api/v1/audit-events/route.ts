import { and, desc, eq } from "drizzle-orm";
import { NextRequest } from "next/server";
import { apiHandler, json } from "@/shared/presentation/api";
import { getDb } from "@/infrastructure/db/client";
import { auditEvents } from "@/infrastructure/db/schema";
export async function GET(request: NextRequest) {
  return apiHandler("audit:read", async (context) => {
    const conditions = [eq(auditEvents.organizationId, context.organizationId)];
    const entityType = request.nextUrl.searchParams.get("entityType");
    const entityId = request.nextUrl.searchParams.get("entityId");
    if (entityType) conditions.push(eq(auditEvents.entityType, entityType));
    if (entityId) conditions.push(eq(auditEvents.entityId, entityId));
    const data = await getDb().select().from(auditEvents).where(and(...conditions)).orderBy(desc(auditEvents.occurredAt)).limit(200);
    return json({ data, nextCursor: null });
  });
}
