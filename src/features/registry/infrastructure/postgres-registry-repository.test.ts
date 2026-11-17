import { beforeEach, describe, expect, it, vi } from "vitest";
import { PgDialect } from "drizzle-orm/pg-core";
import { getDb } from "@/infrastructure/db/client";
import { assets, assetRevisions, people, sites, syncChangeLog } from "@/infrastructure/db/schema";
import { PostgresRegistryRepository } from "./postgres-registry-repository";

vi.mock("@/infrastructure/db/client", () => ({ getDb: vi.fn() }));
const context = {
  organizationId: "10000000-0000-4000-8000-000000000001",
  userId: "10000000-0000-4000-8000-000000000002",
};
const id = "10000000-0000-4000-8000-000000000003";
const companyId = "10000000-0000-4000-8000-000000000004";
const siteId = "10000000-0000-4000-8000-000000000005";
const assetInput = {
  companyId,
  siteId,
  code: "VL-01",
  kind: "VEHICLE",
  makeModel: "Modelo",
  ownershipType: "OWN",
};

function database(selectResults: unknown[][], updated: Record<string, unknown> = { id }) {
  const filters: unknown[] = [];
  const updates: { table: unknown; data: unknown }[] = [];
  const inserts: { table: unknown; data: unknown }[] = [];
  const tx = {
    select: vi.fn(() => {
      const result = selectResults.shift() ?? [];
      const query = {
        from: () => query,
        where: (filter: unknown) => {
          filters.push(filter);
          return query;
        },
        for: async () => result,
        limit: async () => result,
        then: (resolve: (value: unknown[]) => unknown) => Promise.resolve(result).then(resolve),
      };
      return query;
    }),
    update: vi.fn((table: unknown) => ({
      set: (data: unknown) => {
        updates.push({ table, data });
        return { where: () => ({ returning: async () => [updated] }) };
      },
    })),
    insert: vi.fn((table: unknown) => ({
      values: async (data: unknown) => {
        inserts.push({ table, data });
      },
    })),
  };
  vi.mocked(getDb).mockReturnValue({
    transaction: async (work: (value: typeof tx) => unknown) => work(tx),
  } as unknown as ReturnType<typeof getDb>);
  return { tx, filters, updates, inserts };
}

describe("registry edits and removal", () => {
  const repository = new PostgresRegistryRepository();
  beforeEach(() => vi.clearAllMocks());

  it("scopes writes to the organization and rejects missing records", async () => {
    const db = database([[]]);
    await expect(repository.mutate(context, "people", id, null)).rejects.toMatchObject({
      code: "NOT_FOUND",
    });
    const query = new PgDialect().sqlToQuery(
      db.filters[0] as Parameters<PgDialect["sqlToQuery"]>[0],
    );
    expect(query.params).toContain(context.organizationId);
    expect(query.params).toContain(true);
    expect(db.updates).toHaveLength(0);
  });

  it("blocks company removal while active sites are linked", async () => {
    const db = database([[{ id }], [{ id: siteId }], []]);
    await expect(repository.mutate(context, "companies", id, null)).rejects.toMatchObject({
      code: "REGISTRY_IN_USE",
    });
    expect(db.updates).toHaveLength(0);
  });

  it("rejects a site belonging to another company", async () => {
    const db = database([[{ id }], [{ id: companyId }], [{ companyId: "other-company" }]]);
    await expect(repository.mutate(context, "assets", id, assetInput)).rejects.toMatchObject({
      code: "VALIDATION_FAILED",
    });
    expect(db.updates).toHaveLength(0);
  });

  it("accepts a shared site without a company for an asset", async () => {
    const db = database([[{ id }], [{ id: companyId }], [{ companyId: null }]], {
      id,
      ...assetInput,
      revision: 2,
    });
    await repository.mutate(context, "assets", id, assetInput);
    expect(db.updates[0].table).toBe(assets);
  });

  it("renames a site without requiring a company or changing its links", async () => {
    const db = database([[{ id }], [{ companyId }]]);
    await repository.mutate(context, "sites", id, { name: "Patio" });
    expect(db.updates).toEqual([
      { table: sites, data: { name: "Patio", updatedAt: expect.any(Date) } },
    ]);
  });

  it("records the new asset revision and publishes the change to sync", async () => {
    const updated = { id, ...assetInput, revision: 2 };
    const db = database([[{ id }], [{ id: companyId }], [{ companyId }]], updated);
    await repository.mutate(context, "assets", id, assetInput);
    expect(db.updates[0].table).toBe(assets);
    expect(db.inserts).toContainEqual({
      table: assetRevisions,
      data: { assetId: id, revision: 2, snapshot: updated, changedBy: context.userId },
    });
    expect(db.inserts).toContainEqual({
      table: syncChangeLog,
      data: expect.objectContaining({ entityType: "ASSET", revision: 2, changeType: "UPSERT" }),
    });
  });

  it("removes people from choices without deleting inspection history or accounts", async () => {
    const db = database([[{ id }]], { id, active: false });
    await repository.mutate(context, "people", id, null);
    expect(db.updates).toEqual([
      { table: people, data: expect.objectContaining({ active: false }) },
    ]);
    expect(db.inserts).toContainEqual({
      table: syncChangeLog,
      data: expect.objectContaining({ entityType: "PERSON", changeType: "ARCHIVE" }),
    });
  });

  it("validates edits before writing", async () => {
    const db = database([[{ id }]]);
    await expect(repository.mutate(context, "companies", id, { name: " " })).rejects.toThrow();
    expect(db.updates).toHaveLength(0);
  });
});
