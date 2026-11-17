import { expect, it, vi } from "vitest";
import { getDb } from "@/infrastructure/db/client";
import { assetRevisions, auditEvents, syncChangeLog } from "@/infrastructure/db/schema";
import { PostgresRegistryRepository } from "./postgres-registry-repository";

vi.mock("@/infrastructure/db/client", () => ({ getDb: vi.fn() }));
const id = "10000000-0000-4000-8000-000000000001";
const companyId = "10000000-0000-4000-8000-000000000002";
const context = { organizationId: "10000000-0000-4000-8000-000000000003", userId: id };

function database(results: unknown[][]) {
  const inserts: { table: unknown; data: Record<string, unknown> }[] = [];
  const tx = {
    execute: vi.fn(),
    select: () => {
      const result = results.shift() ?? [];
      const query = {
        from: () => query,
        where: () => query,
        for: async () => result,
        then: (resolve: (value: unknown[]) => unknown) => Promise.resolve(result).then(resolve),
      };
      return query;
    },
    insert: (table: unknown) => ({
      values: (data: Record<string, unknown>) => {
        inserts.push({ table, data });
        return {
          returning: async () => [data],
          then: (resolve: (value: unknown) => unknown) => Promise.resolve().then(resolve),
        };
      },
    }),
  };
  vi.mocked(getDb).mockReturnValue({
    transaction: async (work: (tx: unknown) => unknown) => work(tx),
  } as unknown as ReturnType<typeof getDb>);
  return inserts;
}

it.each([
  ["companies", { name: "Empresa offline" }],
  ["sites", { name: "Local sem empresa" }],
  ["people", { name: "Pessoa offline", kind: "DRIVER" }],
] as const)("creates %s using the client ID and publishes it", async (kind, payload) => {
  const inserts = database([[]]);
  expect(await new PostgresRegistryRepository().createFromSync(context, kind, id, payload)).toEqual(
    { id, revision: 1 },
  );
  expect(inserts[0].data).toMatchObject({ id, organizationId: context.organizationId, ...payload });
  expect(inserts.some((entry) => entry.table === auditEvents)).toBe(true);
  expect(inserts.some((entry) => entry.table === syncChangeLog)).toBe(true);
});

it("replays an acknowledged ID without creating another record", async () => {
  const inserts = database([[{ id, organizationId: context.organizationId }]]);
  await new PostgresRegistryRepository().createFromSync(context, "companies", id, {
    name: "Empresa",
  });
  expect(inserts).toHaveLength(0);
});

it("rejects IDs from another organization", async () => {
  const inserts = database([[{ id, organizationId: "another-org" }]]);
  await expect(
    new PostgresRegistryRepository().createFromSync(context, "companies", id, { name: "Empresa" }),
  ).rejects.toMatchObject({ code: "REGISTRY_ID_CONFLICT" });
  expect(inserts).toHaveLength(0);
});

it("rejects an asset with a company outside the organization", async () => {
  const inserts = database([[], []]);
  await expect(
    new PostgresRegistryRepository().createFromSync(context, "assets", id, {
      companyId,
      code: "VL-01",
      kind: "VEHICLE",
      makeModel: "Modelo",
      ownershipType: "OWN",
    }),
  ).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
  expect(inserts).toHaveLength(0);
});

it("creates an asset revision and accepts shared sites", async () => {
  const inserts = database([[], [{ id: companyId }], [{ companyId: null }]]);
  await new PostgresRegistryRepository().createFromSync(context, "assets", id, {
    companyId,
    siteId: id,
    code: "VL-01",
    kind: "VEHICLE",
    makeModel: "Modelo",
    ownershipType: "OWN",
  });
  expect(inserts.find((entry) => entry.table === assetRevisions)?.data).toMatchObject({
    assetId: id,
    revision: 1,
  });
});
