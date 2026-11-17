import { hash } from "bcryptjs";
import { and, asc, eq, sql } from "drizzle-orm";
import { z } from "zod";
import {
  AuthorizationError,
  requirePermission,
  type AuthContext,
} from "@/features/auth/application/auth-context";
import { createUserSchema, updateUserSchema } from "@/features/users/domain/user";
import { getDb } from "@/infrastructure/db/client";
import { auditEvents, mobileAuthSessions, users } from "@/infrastructure/db/schema";
import { conflict, notFound } from "@/shared/domain/errors";

const publicFields = {
  id: users.id,
  displayName: users.displayName,
  employeeNumber: users.employeeNumber,
  roles: users.roles,
  active: users.active,
};

export class UserService {
  async list(context: AuthContext) {
    requirePermission(context, "users:manage");
    return getDb()
      .select(publicFields)
      .from(users)
      .where(eq(users.organizationId, context.organizationId))
      .orderBy(asc(users.displayName));
  }

  async save(context: AuthContext, input: unknown, userId?: string) {
    requirePermission(context, "users:manage");
    if (userId) z.uuid().parse(userId);
    const data = userId ? updateUserSchema.parse(input) : createUserSchema.parse(input);
    const passwordHash = data.password ? await hash(data.password, 12) : undefined;
    return getDb().transaction(async (tx) => {
      await tx.execute(
        sql`select pg_advisory_xact_lock(hashtext(${`users:${context.organizationId}`}))`,
      );
      const [actor] = await tx
        .select({ roles: users.roles })
        .from(users)
        .where(
          and(
            eq(users.id, context.userId),
            eq(users.organizationId, context.organizationId),
            eq(users.active, true),
          ),
        )
        .limit(1);
      if (!actor?.roles.includes("ORG_ADMIN"))
        throw new AuthorizationError("Somente administradores podem gerenciar usuários.");
      await tx.execute(
        sql`select pg_advisory_xact_lock(hashtext(${`user-employee-number:${data.employeeNumber}`}))`,
      );
      const [duplicate] = await tx
        .select({ id: users.id })
        .from(users)
        .where(sql`upper(trim(${users.employeeNumber})) = ${data.employeeNumber}`)
        .limit(1);
      if (duplicate && duplicate.id !== userId)
        throw conflict("EMPLOYEE_NUMBER_IN_USE", "Esta matrícula já está cadastrada.");

      const values = {
        displayName: data.displayName,
        employeeNumber: data.employeeNumber,
        roles: [...new Set(data.roles)],
        passwordHash,
        updatedAt: new Date(),
      };
      let saved;
      let before;
      if (userId && "active" in data) {
        [before] = await tx
          .select(publicFields)
          .from(users)
          .where(and(eq(users.id, userId), eq(users.organizationId, context.organizationId)))
          .for("update");
        if (!before) throw notFound("Usuário não encontrado.");
        if (userId === context.userId && !data.active)
          throw conflict("SELF_DEACTIVATION", "Você não pode desativar sua própria conta.");
        if (
          before.active &&
          before.roles.includes("ORG_ADMIN") &&
          (!data.active || !data.roles.includes("ORG_ADMIN"))
        ) {
          const admins = await tx
            .select({ id: users.id })
            .from(users)
            .where(
              and(
                eq(users.organizationId, context.organizationId),
                eq(users.active, true),
                sql`${users.roles} @> ARRAY['ORG_ADMIN']::user_role[]`,
              ),
            );
          if (admins.length <= 1)
            throw conflict("LAST_ADMIN", "Mantenha pelo menos um administrador ativo.");
        }
        [saved] = await tx
          .update(users)
          .set({ ...values, active: data.active })
          .where(and(eq(users.id, userId), eq(users.organizationId, context.organizationId)))
          .returning(publicFields);
        if (
          passwordHash ||
          !data.active ||
          JSON.stringify(before.roles) !== JSON.stringify(data.roles)
        ) {
          await tx
            .update(mobileAuthSessions)
            .set({ revokedAt: new Date() })
            .where(
              and(
                eq(mobileAuthSessions.userId, userId),
                eq(mobileAuthSessions.organizationId, context.organizationId),
              ),
            );
        }
      } else {
        [saved] = await tx
          .insert(users)
          .values({ ...values, organizationId: context.organizationId })
          .returning(publicFields);
      }
      await tx.insert(auditEvents).values({
        organizationId: context.organizationId,
        entityType: "USER",
        entityId: saved.id,
        action: !before
          ? "CREATED"
          : before.active && !saved.active
            ? "DEACTIVATED"
            : !before.active && saved.active
              ? "REACTIVATED"
              : "UPDATED",
        actorUserId: context.userId,
        changes: [{ before: before ?? null, after: saved }],
        metadata: { passwordChanged: Boolean(passwordHash) },
      });
      return saved;
    });
  }
}
