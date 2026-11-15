import { getServerSession } from "next-auth";
import { authOptions } from "@/features/auth/infrastructure/auth-options";
import { hasPermission, type Permission, type Role } from "@/features/auth/domain/permissions";

export type AuthContext = {
  userId: string;
  organizationId: string;
  roles: Role[];
  displayName: string;
};

export class AuthenticationError extends Error {}
export class AuthorizationError extends Error {}

export async function getAuthContext(): Promise<AuthContext> {
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
