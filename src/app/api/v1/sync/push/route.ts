import { NextRequest } from "next/server";
import { SyncService } from "@/features/sync/application/sync-service";
import { syncPushSchema } from "@/features/sync/domain/sync";
import { apiHandler, json } from "@/shared/presentation/api";
const service = new SyncService();
export async function POST(request: NextRequest) {
  return apiHandler("sync", async (context) =>
    json(await service.push(context, syncPushSchema.parse(await request.json()))),
  );
}
