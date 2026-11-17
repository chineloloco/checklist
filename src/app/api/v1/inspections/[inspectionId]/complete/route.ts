import { NextRequest } from "next/server";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { apiHandler, json, parseIfMatch, requireIdempotencyKey } from "@/shared/presentation/api";

const service = new ChecklistService();
type Params = { params: Promise<{ inspectionId: string }> };

export async function POST(request: NextRequest, { params }: Params) {
  return apiHandler("inspections:write", async (context) => {
    requireIdempotencyKey(request);
    const inspection = await service.completeInspection(
      context,
      (await params).inspectionId,
      parseIfMatch(request),
    );
    return json(inspection, { headers: { ETag: `"rev-${inspection.revision}"` } });
  });
}
