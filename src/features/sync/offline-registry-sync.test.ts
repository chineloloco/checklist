import { afterEach, expect, it, vi } from "vitest";
import { PostgresRegistryRepository } from "@/features/registry/infrastructure/postgres-registry-repository";
import { SyncService } from "./application/sync-service";
import { syncPushSchema } from "./domain/sync";

vi.mock("@/infrastructure/db/client", () => ({ getDb: vi.fn() }));

const id = "10000000-0000-4000-8000-000000000001";
const input = syncPushSchema.parse({
  deviceId: "offline-test",
  operations: [
    {
      operationId: id,
      entityId: id,
      entityType: "COMPANY",
      mutation: "UPSERT",
      clientOccurredAt: "2026-11-16T12:00:00Z",
      payload: { name: "Empresa offline" },
    },
  ],
});
afterEach(() => vi.restoreAllMocks());

it("synchronizes offline registrations with the original client ID", async () => {
  const create = vi
    .spyOn(PostgresRegistryRepository.prototype, "createFromSync")
    .mockResolvedValue({ id, revision: 1 });
  const context = {
    organizationId: id,
    userId: id,
    displayName: "Inspector",
    roles: ["INSPECTOR" as const],
  };
  const response = await new SyncService().push(context, input);
  expect(create).toHaveBeenCalledWith(context, "companies", id, { name: "Empresa offline" });
  expect(response.results[0]).toMatchObject({ status: "APPLIED", entityId: id });
});

it("retains the registry write permission requirement during sync", async () => {
  const create = vi.spyOn(PostgresRegistryRepository.prototype, "createFromSync");
  const response = await new SyncService().push(
    { organizationId: id, userId: id, displayName: "Supervisor", roles: ["SUPERVISOR"] },
    input,
  );
  expect(response.results[0]).toMatchObject({
    status: "REJECTED",
    problem: { detail: "Sem permissão para cadastrar." },
  });
  expect(create).not.toHaveBeenCalled();
});
