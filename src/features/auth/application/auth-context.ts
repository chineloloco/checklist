import { getServerSession } from "next-auth";
import { headers } from "next/headers";
import { authOptions } from "@/features/auth/infrastructure/auth-options";
import { hasPermission, type Permission, type Role } from "@/features/auth/domain/permissions";
import { verifyMobileAccessToken } from "@/features/auth/infrastructure/mobile-password-auth";

export type AuthContext = {
  userId: string;
  organizationId: string;
  roles: Role[];
  displayName: string;
};

export class AuthenticationError extends Error {}
export class AuthorizationError extends Error {}

export async function getAuthContext(): Promise<AuthContext> {
  const authorization = (await headers()).get("authorization");
  if (authorization) {
    const match = authorization.match(/^Bearer\s+(.+)$/i);
    if (!match) throw new AuthenticationError("Token de acesso inválido.");
    try {
      const claims = verifyMobileAccessToken(match[1]);
      return {
        userId: claims.sub,
        organizationId: claims.organizationId,
        roles: claims.roles,
        displayName: claims.displayName
      };
    } catch {
      throw new AuthenticationError("Token de acesso inválido ou expirado.");
    }
  }
  const session = await getServerSession(authOptions);
  if (!session?.user?.id || !session.user.organizationId) {
    throw new AuthenticationError("Autenticação necessária.");
  }
  return {
    userId: session.user.id,
    organizationId: session.user.organizationId,
    roles: session.user.roles,
    displayName: session.user.name ?? session.user.email ?? "Usuário"
  };
}

export function requirePermission(context: AuthContext, permission: Permission): void {
  if (!hasPermission(context.roles, permission)) {
    throw new AuthorizationError(`Permissão necessária: ${permission}`);
  }
}
