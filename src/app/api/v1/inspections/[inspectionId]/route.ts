import { NextRequest } from "next/server";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { updateInspectionSchema } from "@/features/checklists/domain/inspection";
import { apiHandler, json, parseIfMatch } from "@/shared/presentation/api";

const service = new ChecklistService();
type Params = { params: Promise<{ inspectionId: string }> };

export async function GET(_request: Request, { params }: Params) {
  return apiHandler("inspections:read", async (context) => {
    const inspection = await service.getInspection(context, (await params).inspectionId);
    return json(inspection, { headers: { ETag: `"rev-${inspection.revision}"` } });
  });
}

export async function PATCH(request: NextRequest, { params }: Params) {
  return apiHandler("inspections:write", async (context) => {
    const input = updateInspectionSchema.parse({
      ...(await request.json()),
      baseRevision: parseIfMatch(request),
    });
    const inspection = await service.updateInspection(context, (await params).inspectionId, input);
    return json(inspection, { headers: { ETag: `"rev-${inspection.revision}"` } });
  });
}
