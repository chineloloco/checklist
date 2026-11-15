import { NextRequest } from "next/server";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { updateInspectionSchema } from "@/features/checklists/domain/inspection";
import { apiHandler, json, parseIfMatch, requireIdempotencyKey } from "@/shared/presentation/api";

const service = new ChecklistService();
type Params = { params: Promise<{ inspectionId: string }> };

export async function POST(request: NextRequest, { params }: Params) {
  return apiHandler("inspections:correct", async (context) => {
    requireIdempotencyKey(request);
    const input = updateInspectionSchema.parse({
      ...(await request.json()),
      lifecycleStatus: "CORRECTED",
      baseRevision: parseIfMatch(request)
    });
    const inspection = await service.updateInspection(context, (await params).inspectionId, input);
    return json(inspection, { headers: { ETag: `"rev-${inspection.revision}"` } });
  });
}
