import { NextRequest } from "next/server";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { openWeeklyChecklistSchema } from "@/features/checklists/domain/inspection";
import { apiHandler, json, requireIdempotencyKey } from "@/shared/presentation/api";

const service = new ChecklistService();

export async function GET(request: NextRequest) {
  return apiHandler("inspections:read", async (context) => {
    const params = request.nextUrl.searchParams;
    const data = await service.listWeekly(context, {
      weekStartDate: params.get("weekStartDate") ?? undefined,
      assetId: params.get("assetId") ?? undefined,
      templateId: params.get("templateId") ?? undefined,
    });
    return json({ data });
  });
}

export async function POST(request: NextRequest) {
  return apiHandler("inspections:write", async (context) => {
    requireIdempotencyKey(request);
    const created = await service.openWeekly(
      context,
      openWeeklyChecklistSchema.parse(await request.json()),
    );
    return json(created, {
      status: 201,
      headers: { Location: `/api/v1/weekly-checklists/${created.id}` },
    });
  });
}
