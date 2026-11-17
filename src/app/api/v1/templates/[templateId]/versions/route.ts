import { z } from "zod";
import { NextRequest } from "next/server";
import { TemplateService } from "@/features/templates/application/template-service";
import { apiHandler, json, requireIdempotencyKey } from "@/shared/presentation/api";
const service = new TemplateService();
type Params = { params: Promise<{ templateId: string }> };
const schema = z.object({ basedOnVersionId: z.uuid() });
export async function POST(request: NextRequest, { params }: Params) {
  return apiHandler("templates:write", async (context) => {
    requireIdempotencyKey(request);
    const body = schema.parse(await request.json());
    return json(
      await service.createVersion(context, (await params).templateId, body.basedOnVersionId),
      { status: 201 },
    );
  });
}
