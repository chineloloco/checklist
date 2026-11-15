import { apiHandler, json } from "@/shared/presentation/api";
import { permissionsForRoles } from "@/features/auth/domain/permissions";

export async function GET() {
  return apiHandler("dashboard:read", async (context) =>
    json({
      userId: context.userId,
      organizationId: context.organizationId,
      displayName: context.displayName,
      timezone: process.env.DEFAULT_TIMEZONE ?? "America/Fortaleza",
      weekStartsOn: "MONDAY",
      roles: context.roles,
      permissions: permissionsForRoles(context.roles)
    })
  );
}
