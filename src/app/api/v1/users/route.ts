import { NextRequest } from "next/server";
import { UserService } from "@/features/users/application/user-service";
import { apiHandler, json } from "@/shared/presentation/api";

export async function GET() {
  return apiHandler("users:manage", async (context) =>
    json({ data: await new UserService().list(context) }),
  );
}
export async function POST(request: NextRequest) {
  return apiHandler("users:manage", async (context) =>
    json(await new UserService().save(context, await request.json()), { status: 201 }),
  );
}
