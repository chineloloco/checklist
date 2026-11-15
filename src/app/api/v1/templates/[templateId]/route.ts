import { apiHandler, json } from "@/shared/presentation/api";
import { TemplateService } from "@/features/templates/application/template-service";

const service = new TemplateService();
type Params = { params: Promise<{ templateId: string }> };

export async function GET(_request: Request, { params }: Params) {
  return apiHandler("templates:read", async (context) => json(await service.detail(context, (await params).templateId)));
}

export async function DELETE(_request: Request, { params }: Params) {
  return apiHandler("templates:write", async (context) => {
    await service.deleteUnusedDraft(context, (await params).templateId);
    return new Response(null, { status: 204 });
  });
}
