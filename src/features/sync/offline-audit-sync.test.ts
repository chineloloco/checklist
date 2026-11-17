import { beforeEach, expect, it, vi } from "vitest";
import { getDb } from "@/infrastructure/db/client";
import { SyncService } from "./application/sync-service";
import { syncPushSchema } from "./domain/sync";
import type { AuthContext } from "@/features/auth/application/auth-context";

vi.mock("@/infrastructure/db/client", () => ({ getDb: vi.fn() }));
const id = "10000000-0000-4000-8000-000000000001";
const context: AuthContext = {
  userId: id,
  organizationId: id,
  displayName: "Maria",
  roles: ["INSPECTOR"],
};
const input = syncPushSchema.parse({
  deviceId: "device",
  operations: [
    {
      operationId: id,
      entityId: id,
      entityType: "AUDIT_EVENT",
      mutation: "VOID",
      clientOccurredAt: "2026-11-16T12:00:00Z",
      payload: {
        localDate: "2026-11-16",
        assetCode: "VL-01",
        actorUserId: "spoofed",
        actorDisplayName: "Spoofed",
      },
    },
  ],
});
beforeEach(() => vi.clearAllMocks());

it("attributes offline deactivation to the authenticated user and deduplicates retries", async () => {
  let event: Record<string, unknown> | undefined;
  const db = {
    insert: () => ({
      values: (value: Record<string, unknown>) => {
        const replay = Boolean(event);
        event ??= value;
        return { onConflictDoNothing: () => ({ returning: async () => (replay ? [] : [{ id }]) }) };
      },
    }),
    select: () => ({ from: () => ({ where: () => ({ limit: async () => [event] }) }) }),
  };
  vi.mocked(getDb).mockReturnValue(db as unknown as ReturnType<typeof getDb>);
  const service = new SyncService();
  expect((await service.push(context, input)).results[0].status).toBe("APPLIED");
  expect((await service.push(context, input)).results[0].status).toBe("ALREADY_APPLIED");
  expect(event).toMatchObject({ actorUserId: context.userId, action: "LOCAL_DRAFT_DEACTIVATED" });
  expect(event).not.toHaveProperty("actorDisplayName");
  expect(JSON.stringify(event)).not.toContain("spoofed");
  const changed = structuredClone(input);
  changed.operations[0].payload.assetCode = "VL-02";
  expect((await service.push(context, changed)).results[0].status).toBe("REJECTED");
});

it("rejects offline audit writes by read-only users", async () => {
  expect(
    (await new SyncService().push({ ...context, roles: ["AUDITOR"] }, input)).results[0].status,
  ).toBe("REJECTED");
  expect(getDb).not.toHaveBeenCalled();
});
