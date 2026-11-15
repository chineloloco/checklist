import { NextRequest } from "next/server";
import { apiHandler, json, parseIfMatch, requireIdempotencyKey } from "@/shared/presentation/api";
import { TemplateService } from "@/features/templates/application/template-service";

const service = new TemplateService();
type Params = { params: Promise<{ versionId: string }> };

export async function POST(request: NextRequest, { params }: Params) {
  return apiHandler("templates:publish", async (context) => {
    requireIdempotencyKey(request);
    const version = await service.publish(context, (await params).versionId, parseIfMatch(request));
    return json(version, { headers: { ETag: `"rev-${version.revision}"` } });
  });
}
