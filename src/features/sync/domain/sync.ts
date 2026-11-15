import { z } from "zod";

export const syncOperationSchema = z.object({
  operationId: z.uuid(),
  entityType: z.enum(["WEEKLY_CHECKLIST", "INSPECTION"]),
  mutation: z.enum(["UPSERT", "COMPLETE", "VOID"]),
  entityId: z.uuid(),
  baseRevision: z.number().int().min(1).nullable().optional(),
  clientOccurredAt: z.iso.datetime({ offset: true }),
  payload: z.record(z.string(), z.unknown())
});
export const syncPushSchema = z.object({
  deviceId: z.string().min(1).max(100),
  operations: z.array(syncOperationSchema).min(1).max(100)
});
