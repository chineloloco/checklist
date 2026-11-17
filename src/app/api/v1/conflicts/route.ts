import { NextRequest } from "next/server";
import { ConflictService } from "@/features/conflicts/application/conflict-service";
import { apiHandler, json } from "@/shared/presentation/api";
const service = new ConflictService();
export async function GET(request: NextRequest) {
  return apiHandler("conflicts:read", async (context) =>
    json({
      data: await service.list(
        context,
        (request.nextUrl.searchParams.get("status") as "OPEN" | "RESOLVED" | null) ?? undefined,
      ),
    }),
  );
}
