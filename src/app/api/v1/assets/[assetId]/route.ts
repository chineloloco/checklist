import { z } from "zod";
import { RegistryService } from "@/features/registry/application/registry-service";
import { apiHandler, json } from "@/shared/presentation/api";
const service = new RegistryService();
type Params = { params: Promise<{ assetId: string }> };
export async function PATCH(request: Request, { params }: Params) {
  return apiHandler("cadastros:write", async (context) =>
    json(
      await service.update(
        context,
        "assets",
        z.uuid().parse((await params).assetId),
        await request.json(),
      ),
    ),
  );
}
export async function DELETE(_request: Request, { params }: Params) {
  return apiHandler("cadastros:write", async (context) => {
    await service.remove(context, "assets", z.uuid().parse((await params).assetId));
    return new Response(null, { status: 204 });
  });
}
