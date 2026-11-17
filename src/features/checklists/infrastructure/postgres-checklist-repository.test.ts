import { expect, it, vi } from "vitest";
import { PgDialect } from "drizzle-orm/pg-core";
import { getDb } from "@/infrastructure/db/client";
import { openWeeklyChecklistSchema } from "../domain/inspection";
import { PostgresChecklistRepository } from "./postgres-checklist-repository";

vi.mock("@/infrastructure/db/client", () => ({ getDb: vi.fn() }));
const id = "10000000-0000-4000-8000-000000000001";
const versionId = "10000000-0000-4000-8000-000000000002";

it.each([versionId, undefined])(
  "pins an offline version and keeps older clients compatible (%s)",
  async (requestedVersion) => {
    const joins: unknown[] = [];
    const leftJoin = vi.fn((_table: unknown, filter: unknown) => {
      joins.push(filter);
    });
    const inserted: Record<string, unknown>[] = [];
    const results = [
      [
        {
          assetId: id,
          templateId: id,
          versionId: requestedVersion ?? versionId,
          operationConfigId: id,
          timezone: "America/Sao_Paulo",
        },
      ],
      [],
    ];
    const tx = {
      select: () => {
        const result = results.shift();
        const query = {
          from: () => query,
          leftJoin: (_table: unknown, filter: unknown) => {
            leftJoin(_table, filter);
            return query;
          },
          innerJoin: (_table: unknown, filter: unknown) => {
            joins.push(filter);
            return query;
          },
          where: () => query,
          orderBy: () => query,
          limit: async () => result,
        };
        return query;
      },
      execute: vi.fn(),
      insert: () => ({
        values: (data: Record<string, unknown>) => {
          inserted.push(data);
          return { returning: async () => [{ ...data, revision: 1 }] };
        },
      }),
    };
    vi.mocked(getDb).mockReturnValue({
      transaction: async (work: (value: typeof tx) => unknown) => work(tx),
    } as unknown as ReturnType<typeof getDb>);
    const input = openWeeklyChecklistSchema.parse({
      assetId: id,
      templateId: id,
      templateVersionId: requestedVersion,
      operationConfigId: requestedVersion ? id : undefined,
      localDate: "2026-11-16",
    });
    await new PostgresChecklistRepository().openWeekly({ organizationId: id, userId: id }, input);
    expect(leftJoin).toHaveBeenCalledOnce();
    const params = new PgDialect().sqlToQuery(
      joins[2] as Parameters<PgDialect["sqlToQuery"]>[0],
    ).params;
    if (requestedVersion) expect(params).toContain(versionId);
    else expect(params).not.toContain(versionId);
    const configQuery = new PgDialect().sqlToQuery(
      joins[3] as Parameters<PgDialect["sqlToQuery"]>[0],
    );
    if (requestedVersion) {
      expect(configQuery.params).toContain(id);
      expect(configQuery.sql).toContain('"operation_configs"."organization_id"');
      expect(configQuery.sql).toContain('"operation_configs"."template_id"');
    }
    expect(inserted[0].templateVersionId).toBe(versionId);
  },
);
