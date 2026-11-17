import { beforeEach, describe, expect, it, vi } from "vitest";
import { compare } from "bcryptjs";
import { PgDialect } from "drizzle-orm/pg-core";
import { getDb } from "@/infrastructure/db/client";
import { auditEvents, users } from "@/infrastructure/db/schema";
import { UserService } from "./user-service";
import { createUserSchema } from "../domain/user";
import type { AuthContext } from "@/features/auth/application/auth-context";

vi.mock("@/infrastructure/db/client", () => ({ getDb: vi.fn() }));
const id = "10000000-0000-4000-8000-000000000001";
const otherId = "10000000-0000-4000-8000-000000000002";
const context: AuthContext = {
  userId: id,
  organizationId: id,
  displayName: "Admin",
  roles: ["ORG_ADMIN"],
};
const input = {
  displayName: "Maria Silva",
  employeeNumber: "001234",
  roles: ["INSPECTOR"],
  password: "uma-senha-teste",
};
const existing = { id: otherId, ...input, active: true };

function database(selectResults: unknown[][]) {
  const writes: { table: unknown; values: Record<string, unknown> }[] = [];
  const filters: unknown[] = [];
  const tx = {
    execute: vi.fn(),
    select: vi.fn(() => {
      const result = selectResults.shift() ?? [];
      const query = {
        from: () => query,
        where: (filter: unknown) => {
          filters.push(filter);
          return query;
        },
        limit: async () => result,
        for: async () => result,
        then: (resolve: (value: unknown[]) => unknown) => Promise.resolve(result).then(resolve),
      };
      return query;
    }),
    insert: (table: unknown) => ({
      values: (values: Record<string, unknown>) => {
        writes.push({ table, values });
        return {
          returning: async () => [
            {
              id: otherId,
              displayName: values.displayName,
              employeeNumber: values.employeeNumber,
              roles: values.roles,
              active: true,
            },
          ],
        };
      },
    }),
    update: (table: unknown) => ({
      set: (values: Record<string, unknown>) => ({
        where: (filter: unknown) => {
          writes.push({ table, values });
          filters.push(filter);
          return { returning: async () => [{ ...existing, ...values, passwordHash: undefined }] };
        },
      }),
    }),
  };
  vi.mocked(getDb).mockReturnValue({
    transaction: async (work: (value: typeof tx) => unknown) => work(tx),
  } as unknown as ReturnType<typeof getDb>);
  return { writes, filters, tx };
}

beforeEach(() => vi.clearAllMocks());

describe("user administration", () => {
  it.each(["INSPECTOR", "SUPERVISOR", "AUDITOR"] as const)(
    "denies management to %s",
    async (role) => {
      await expect(new UserService().save({ ...context, roles: [role] }, input)).rejects.toThrow();
      expect(getDb).not.toHaveBeenCalled();
    },
  );
  it("stores a password hash and audits only public user fields", async () => {
    const { writes } = database([[{ roles: ["ORG_ADMIN"] }], []]);
    const saved = await new UserService().save(context, { ...input, employeeNumber: " 00ab-12 " });
    const stored = writes.find((write) => write.table === users)!.values;
    expect(await compare(input.password, String(stored.passwordHash))).toBe(true);
    expect(saved.employeeNumber).toBe("00AB-12");
    expect(saved).not.toHaveProperty("passwordHash");
    const event = writes.find((write) => write.table === auditEvents)!.values;
    expect(event).toMatchObject({ actorUserId: id, entityType: "USER", action: "CREATED" });
    expect(JSON.stringify(event)).not.toContain(input.password);
    expect(JSON.stringify(event)).not.toContain(stored.passwordHash);
  });
  it("rejects duplicate employeeNumber without writing", async () => {
    const { writes } = database([[{ roles: ["ORG_ADMIN"] }], [{ id: otherId }]]);
    await expect(
      new UserService().save(context, { ...input, password: undefined, active: true }, id),
    ).rejects.toMatchObject({ code: "EMPLOYEE_NUMBER_IN_USE" });
    expect(writes).toEqual([]);
  });
  it("does not allow editing users from another organization", async () => {
    const { writes, filters } = database([[{ roles: ["ORG_ADMIN"] }], [], []]);
    await expect(
      new UserService().save(context, { ...input, password: undefined, active: false }, otherId),
    ).rejects.toMatchObject({ code: "NOT_FOUND" });
    expect(writes).toEqual([]);
    const query = new PgDialect().sqlToQuery(filters[2] as Parameters<PgDialect["sqlToQuery"]>[0]);
    expect(query.sql).toContain('"users"."organization_id"');
    expect(query.params).toContain(context.organizationId);
  });
  it("protects the last active administrator", async () => {
    const { writes } = database([
      [{ roles: ["ORG_ADMIN"] }],
      [],
      [{ ...existing, roles: ["ORG_ADMIN"] }],
      [{ id: otherId }],
    ]);
    await expect(
      new UserService().save(context, { ...input, password: undefined, active: false }, otherId),
    ).rejects.toMatchObject({ code: "LAST_ADMIN" });
    expect(writes).toEqual([]);
  });
  it("rechecks administrator permissions inside the transaction", async () => {
    const { writes } = database([[{ roles: ["INSPECTOR"] }]]);
    await expect(
      new UserService().save(context, { ...input, password: undefined, active: true }, otherId),
    ).rejects.toThrow("Somente administradores");
    expect(writes).toEqual([]);
  });
  it("rejects empty roles and passwords beyond bcrypt's byte limit", () => {
    expect(createUserSchema.safeParse({ ...input, roles: [] }).success).toBe(false);
    expect(createUserSchema.safeParse({ ...input, password: "á".repeat(37) }).success).toBe(false);
  });
  it("does not allow deactivating the current account", async () => {
    const { writes } = database([[{ roles: ["ORG_ADMIN"] }], [], [{ ...existing, id }]]);
    await expect(
      new UserService().save(context, { ...input, password: undefined, active: false }, id),
    ).rejects.toMatchObject({ code: "SELF_DEACTIVATION" });
    expect(writes).toEqual([]);
  });
  it("does not allow removing the last active administrator", async () => {
    const { writes } = database([
      [{ roles: ["ORG_ADMIN"] }],
      [],
      [{ ...existing, roles: ["ORG_ADMIN"] }],
      [{ id: otherId }],
    ]);
    await expect(
      new UserService().save(context, { ...input, password: undefined, active: true }, otherId),
    ).rejects.toMatchObject({ code: "LAST_ADMIN" });
    expect(writes).toEqual([]);
  });
});
