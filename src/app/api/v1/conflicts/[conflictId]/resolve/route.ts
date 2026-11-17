import { NextRequest } from "next/server";
import { ConflictService } from "@/features/conflicts/application/conflict-service";
import { resolveConflictSchema } from "@/features/conflicts/domain/conflict";
import { apiHandler, json, parseIfMatch, requireIdempotencyKey } from "@/shared/presentation/api";
const service = new ConflictService();
type Params = { params: Promise<{ conflictId: string }> };
export async function POST(request: NextRequest, { params }: Params) {
  return apiHandler("conflicts:resolve", async (context) => {
    requireIdempotencyKey(request);
    return json(
      await service.resolve(
        context,
        (await params).conflictId,
        parseIfMatch(request),
        resolveConflictSchema.parse(await request.json()),
      ),
    );
  });
}
