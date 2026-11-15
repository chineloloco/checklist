import { apiHandler, json } from "@/shared/presentation/api";
import { ChecklistService } from "@/features/checklists/application/checklist-service";

const service = new ChecklistService();
type Params = { params: Promise<{ weeklyChecklistId: string }> };

export async function GET(_request: Request, { params }: Params) {
  return apiHandler("inspections:read", async (context) =>
    json(await service.weeklyView(context, (await params).weeklyChecklistId))
  );
}
