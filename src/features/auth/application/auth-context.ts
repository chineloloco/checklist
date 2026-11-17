import { getServerSession } from "next-auth";
import { headers } from "next/headers";
import { authOptions } from "@/features/auth/infrastructure/auth-options";
import { hasPermission, type Permission, type Role } from "@/features/auth/domain/permissions";
import { verifyMobileAccessToken } from "@/features/auth/infrastructure/mobile-password-auth";
import { and, eq } from "drizzle-orm";
import { getDb } from "@/infrastructure/db/client";
import { users } from "@/infrastructure/db/schema";

export type AuthContext = {
  userId: string;
  organizationId: string;
  roles: Role[];
  displayName: string;
};

export class AuthenticationError extends Error {}
export class AuthorizationError extends Error {}

async function activeContext(userId: string, organizationId: string): Promise<AuthContext> {
  const [user] = await getDb()
    .select({
      userId: users.id,
      organizationId: users.organizationId,
      roles: users.roles,
      displayName: users.displayName,
    })
    .from(users)
    .where(
      and(eq(users.id, userId), eq(users.organizationId, organizationId), eq(users.active, true)),
    )
    .limit(1);
  if (!user) throw new AuthenticationError("Conta desativada ou indisponível.");
  return user;
}

export async function getAuthContext(): Promise<AuthContext> {
  const authorization = (await headers()).get("authorization");
  if (authorization) {
    const match = authorization.match(/^Bearer\s+(.+)$/i);
    if (!match) throw new AuthenticationError("Token de acesso inválido.");
    try {
      const claims = verifyMobileAccessToken(match[1]);
      return await activeContext(claims.sub, claims.organizationId);
    } catch {
      throw new AuthenticationError("Token de acesso inválido ou expirado.");
    }
  }
  const session = await getServerSession(authOptions);
  if (!session?.user?.id || !session.user.organizationId) {
    throw new AuthenticationError("Autenticação necessária.");
  }
  return activeContext(session.user.id, session.user.organizationId);
}

export function requirePermission(context: AuthContext, permission: Permission): void {
  if (!hasPermission(context.roles, permission)) {
    throw new AuthorizationError(`Permissão necessária: ${permission}`);
  }
}
