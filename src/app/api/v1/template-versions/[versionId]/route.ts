import { NextRequest } from "next/server";
import { apiHandler, json, parseIfMatch } from "@/shared/presentation/api";
import { TemplateService } from "@/features/templates/application/template-service";
import { updateTemplateVersionSchema } from "@/features/templates/domain/template";

const service = new TemplateService();
type Params = { params: Promise<{ versionId: string }> };

export async function GET(_request: Request, { params }: Params) {
  return apiHandler("templates:read", async (context) => {
    const version = await service.version(context, (await params).versionId);
    return json(version, { headers: { ETag: `"rev-${version.revision}"` } });
  });
}

export async function PATCH(request: NextRequest, { params }: Params) {
  return apiHandler("templates:write", async (context) => {
    const baseRevision = parseIfMatch(request);
    const body = updateTemplateVersionSchema.parse({ ...(await request.json()), baseRevision });
    const version = await service.updateDraft(context, (await params).versionId, body);
    return json(version, { headers: { ETag: `"rev-${version.revision}"` } });
  });
}
