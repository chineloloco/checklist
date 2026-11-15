import { NextRequest } from "next/server";
import { RegistryService } from "@/features/registry/application/registry-service";
import { createPersonSchema } from "@/features/registry/domain/registry";
import { apiHandler, json, requireIdempotencyKey } from "@/shared/presentation/api";
const service = new RegistryService();
export async function GET() { return apiHandler("cadastros:read", async (context) => json({ data: await service.listPeople(context) })); }
export async function POST(request: NextRequest) { return apiHandler("cadastros:write", async (context) => { requireIdempotencyKey(request); return json(await service.createPerson(context, createPersonSchema.parse(await request.json())), { status: 201 }); }); }
