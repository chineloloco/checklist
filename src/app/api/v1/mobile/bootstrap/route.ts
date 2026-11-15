import { NextRequest } from "next/server";
import { SyncService } from "@/features/sync/application/sync-service";
import { apiHandler, json } from "@/shared/presentation/api";
const service = new SyncService();
export async function GET(request: NextRequest) {
  return apiHandler("sync", async (context) => {
    const cursor = request.nextUrl.searchParams.get("sinceCursor");
    return json(await service.bootstrap(context, cursor ? Number(cursor) : undefined));
  });
}
