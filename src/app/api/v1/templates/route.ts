import { NextRequest } from "next/server";
import { apiHandler, json, requireIdempotencyKey } from "@/shared/presentation/api";
import { TemplateService } from "@/features/templates/application/template-service";
import { createTemplateSchema } from "@/features/templates/domain/template";

const service = new TemplateService();

export async function GET(request: NextRequest) {
  return apiHandler("templates:read", async (context) => {
    const status = request.nextUrl.searchParams.get("status") as
      "DRAFT" | "ACTIVE" | "ARCHIVED" | null;
    const data = await service.list(context, status ?? undefined);
    return json({ data, nextCursor: null });
  });
}

export async function POST(request: NextRequest) {
  return apiHandler("templates:write", async (context) => {
    requireIdempotencyKey(request);
    const input = createTemplateSchema.parse(await request.json());
    const created = await service.create(context, input);
    return json(created, {
      status: 201,
      headers: { Location: `/api/v1/templates/${created.template.id}` },
    });
  });
}
