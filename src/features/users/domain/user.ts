import { z } from "zod";
import { employeeNumberSchema } from "@/features/auth/domain/employee-number";

export const userRoleLabels = {
  ORG_ADMIN: "Administrador",
  TEMPLATE_MANAGER: "Gestor de modelos",
  FLEET_MANAGER: "Gestor de frota",
  SUPERVISOR: "Supervisor",
  INSPECTOR: "Inspetor",
  AUDITOR: "Auditor",
} as const;

const passwordSchema = z
  .string()
  .min(10, "Use pelo menos 10 caracteres.")
  .refine(
    (value) => new TextEncoder().encode(value).length <= 72,
    "A senha deve ter até 72 bytes.",
  );
const fields = {
  displayName: z.string().trim().min(2).max(200),
  employeeNumber: employeeNumberSchema,
  roles: z
    .array(
      z.enum(
        Object.keys(userRoleLabels) as [
          keyof typeof userRoleLabels,
          ...(keyof typeof userRoleLabels)[],
        ],
      ),
    )
    .min(1)
    .max(6),
};
export const createUserSchema = z.object({ ...fields, password: passwordSchema });
export const updateUserSchema = z.object({
  ...fields,
  active: z.boolean(),
  password: passwordSchema.optional(),
});
export type ManagedUser = {
  id: string;
  displayName: string;
  employeeNumber: string | null;
  roles: (keyof typeof userRoleLabels)[];
  active: boolean;
};
