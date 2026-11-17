import { apiHandler, json } from "@/shared/presentation/api";
import { TemplateService } from "@/features/templates/application/template-service";
import { updateTemplateMetadataSchema } from "@/features/templates/domain/template";

const service = new TemplateService();
type Params = { params: Promise<{ templateId: string }> };

export async function GET(_request: Request, { params }: Params) {
  return apiHandler("templates:read", async (context) =>
    json(await service.detail(context, (await params).templateId)),
  );
}

export async function PATCH(request: Request, { params }: Params) {
  return apiHandler("templates:write", async (context) => {
    const input = updateTemplateMetadataSchema.parse(await request.json());
    return json(await service.updateMetadata(context, (await params).templateId, input));
  });
}

export async function DELETE(_request: Request, { params }: Params) {
  return apiHandler("templates:write", async (context) => {
    await service.deleteUnusedTemplate(context, (await params).templateId);
    return new Response(null, { status: 204 });
  });
}
