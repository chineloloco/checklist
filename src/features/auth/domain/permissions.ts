export const permissions = [
  "dashboard:read",
  "cadastros:read",
  "cadastros:write",
  "templates:read",
  "templates:write",
  "templates:publish",
  "templates:archive",
  "inspections:read",
  "inspections:write",
  "inspections:correct",
  "conflicts:read",
  "conflicts:resolve",
  "audit:read",
  "sync"
] as const;

export type Permission = (typeof permissions)[number];
export type Role =
  | "ORG_ADMIN"
  | "TEMPLATE_MANAGER"
  | "FLEET_MANAGER"
  | "SUPERVISOR"
  | "INSPECTOR"
  | "AUDITOR";

const rolePermissions: Record<Role, Permission[]> = {
  ORG_ADMIN: [...permissions],
  TEMPLATE_MANAGER: [
    "dashboard:read",
    "templates:read",
    "templates:write",
    "templates:publish",
    "templates:archive",
    "audit:read"
  ],
  FLEET_MANAGER: [
    "dashboard:read",
    "cadastros:read",
    "cadastros:write",
    "templates:read",
    "inspections:read",
    "conflicts:read"
  ],
  SUPERVISOR: [
    "dashboard:read",
    "cadastros:read",
    "templates:read",
    "inspections:read",
    "inspections:write",
    "inspections:correct",
    "conflicts:read",
    "conflicts:resolve",
    "audit:read",
    "sync"
  ],
  INSPECTOR: [
    "dashboard:read",
    "cadastros:read",
    "templates:read",
    "inspections:read",
    "inspections:write",
    "sync"
  ],
  AUDITOR: ["dashboard:read", "cadastros:read", "templates:read", "inspections:read", "audit:read"]
};

export function permissionsForRoles(roles: Role[]): Permission[] {
  return [...new Set(roles.flatMap((role) => rolePermissions[role] ?? []))];
}

export function hasPermission(roles: Role[], permission: Permission): boolean {
  return roles.some((role) => rolePermissions[role]?.includes(permission));
}
