import { apiHandler, json } from "@/shared/presentation/api";
import { TemplateService } from "@/features/templates/application/template-service";

const service = new TemplateService();
type Params = { params: Promise<{ templateId: string }> };

export async function POST(_request: Request, { params }: Params) {
  return apiHandler("templates:archive", async (context) => json(await service.archive(context, (await params).templateId)));
}
