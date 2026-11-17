import { z } from "zod";
import { RegistryService } from "@/features/registry/application/registry-service";
import { apiHandler, json } from "@/shared/presentation/api";
const service = new RegistryService();
type Params = { params: Promise<{ companyId: string }> };
export async function PATCH(request: Request, { params }: Params) {
  return apiHandler("cadastros:write", async (context) =>
    json(
      await service.update(
        context,
        "companies",
        z.uuid().parse((await params).companyId),
        await request.json(),
      ),
    ),
  );
}
export async function DELETE(_request: Request, { params }: Params) {
  return apiHandler("cadastros:write", async (context) => {
    await service.remove(context, "companies", z.uuid().parse((await params).companyId));
    return new Response(null, { status: 204 });
  });
}
