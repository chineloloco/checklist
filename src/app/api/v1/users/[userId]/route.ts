import { NextRequest } from "next/server";
import { UserService } from "@/features/users/application/user-service";
import { apiHandler, json } from "@/shared/presentation/api";

export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ userId: string }> },
) {
  return apiHandler("users:manage", async (context) =>
    json(await new UserService().save(context, await request.json(), (await params).userId)),
  );
}
