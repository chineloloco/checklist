import { NextRequest } from "next/server";
import { apiHandler, json } from "@/shared/presentation/api";
import { listAuditEvents } from "@/features/audit/infrastructure/audit-query";
import { z } from "zod";
export async function GET(request: NextRequest) {
  return apiHandler("audit:read", async (context) => {
    const entityType = request.nextUrl.searchParams.get("entityType");
    const entityId = request.nextUrl.searchParams.get("entityId");
    if (entityId) z.uuid().parse(entityId);
    const data = await listAuditEvents(context.organizationId, entityType, entityId);
    return json({ data, nextCursor: null });
  });
}
