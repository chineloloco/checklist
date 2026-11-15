import { NextRequest } from "next/server";
import { SyncService } from "@/features/sync/application/sync-service";
import { apiHandler, json } from "@/shared/presentation/api";
import { validationFailed } from "@/shared/domain/errors";
const service = new SyncService();
export async function GET(request: NextRequest) {
  return apiHandler("sync", async (context) => {
    const cursor = Number(request.nextUrl.searchParams.get("cursor"));
    const limit = Math.min(Number(request.nextUrl.searchParams.get("limit") ?? 200), 500);
    if (!Number.isInteger(cursor) || cursor < 0) throw validationFailed("Cursor inválido.");
    return json(await service.pull(context, cursor, limit));
  });
}
