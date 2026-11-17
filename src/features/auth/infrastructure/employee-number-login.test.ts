import { beforeEach, afterEach, expect, it, vi } from "vitest";
import { hash } from "bcryptjs";
import { PgDialect } from "drizzle-orm/pg-core";
import { getDb } from "@/infrastructure/db/client";
import { loginWithPassword, verifyMobileAccessToken } from "./mobile-password-auth";
import { employeeNumberSchema } from "../domain/employee-number";

vi.mock("@/infrastructure/db/client", () => ({ getDb: vi.fn() }));
beforeEach(() => {
  vi.clearAllMocks();
  vi.stubEnv("AUTH_ALLOW_CREDENTIALS", "true");
  vi.stubEnv("MOBILE_AUTH_SECRET", "test-only-secret-with-more-than-32-characters");
});
afterEach(() => vi.unstubAllEnvs());

it("authenticates with a text employee number without requiring email", async () => {
  let filter: unknown;
  const id = "10000000-0000-4000-8000-000000000001";
  const user = {
    id,
    organizationId: id,
    employeeNumber: "001234",
    email: null,
    displayName: "Maria",
    roles: ["INSPECTOR"],
    passwordHash: await hash("uma-senha-teste", 4),
  };
  const db = {
    select: () => ({
      from: () => ({
        where: (value: unknown) => {
          filter = value;
          return { limit: async () => [user] };
        },
      }),
    }),
    insert: () => ({ values: () => ({ returning: async () => [{ id }] }) }),
    update: () => ({ set: () => ({ where: async () => [] }) }),
  };
  vi.mocked(getDb).mockReturnValue(db as unknown as ReturnType<typeof getDb>);
  const result = await loginWithPassword({
    employeeNumber: " 001234 ",
    password: "uma-senha-teste",
  });
  const query = new PgDialect().sqlToQuery(filter as Parameters<PgDialect["sqlToQuery"]>[0]);
  expect(query.sql).toContain('"users"."employee_number"');
  expect(query.params).toContain("001234");
  expect(result.user).toMatchObject({
    employeeNumber: "001234",
    email: null,
    displayName: "Maria",
  });
  expect(verifyMobileAccessToken(result.accessToken)).toMatchObject({
    sub: id,
    employeeNumber: "001234",
    email: null,
  });
  await expect(
    loginWithPassword({ employeeNumber: "001234", password: "senha-errada" }),
  ).rejects.toMatchObject({
    code: "INVALID_CREDENTIALS",
    message: "Matrícula ou senha inválidas.",
  });
});

it("normalizes letters while preserving leading zeroes", () => {
  expect(employeeNumberSchema.parse(" 00ab-12 ")).toBe("00AB-12");
  expect(employeeNumberSchema.parse("000001")).toBe("000001");
  expect(employeeNumberSchema.safeParse("pessoa@example.com").success).toBe(false);
  expect(employeeNumberSchema.safeParse(1234).success).toBe(false);
  expect(employeeNumberSchema.safeParse(" ").success).toBe(false);
});
