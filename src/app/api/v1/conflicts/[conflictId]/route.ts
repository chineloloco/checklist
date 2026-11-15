import { ConflictService } from "@/features/conflicts/application/conflict-service";
import { apiHandler, json } from "@/shared/presentation/api";
const service = new ConflictService();
type Params = { params: Promise<{ conflictId: string }> };
export async function GET(_request: Request, { params }: Params) { return apiHandler("conflicts:read", async (context) => json(await service.detail(context, (await params).conflictId))); }
