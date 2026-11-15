import { NextRequest } from "next/server";
import { RegistryService } from "@/features/registry/application/registry-service";
import { assignTemplateSchema } from "@/features/registry/domain/registry";
import { apiHandler, json, requireIdempotencyKey } from "@/shared/presentation/api";
const service = new RegistryService();
type Params = { params: Promise<{ assetId: string }> };
export async function POST(request: NextRequest, { params }: Params) { return apiHandler("cadastros:write", async (context) => { requireIdempotencyKey(request); return json(await service.assignTemplate(context, (await params).assetId, assignTemplateSchema.parse(await request.json())), { status: 201 }); }); }
