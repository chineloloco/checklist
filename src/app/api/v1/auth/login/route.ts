import { z } from "zod";
import { loginWithPassword } from "@/features/auth/infrastructure/mobile-password-auth";
import { json } from "@/shared/presentation/api";
import { problemResponse } from "@/shared/presentation/problem";
import { employeeNumberSchema } from "@/features/auth/domain/employee-number";

const schema = z.object({
  employeeNumber: employeeNumberSchema,
  password: z.string().min(1).max(200),
  deviceId: z.string().trim().min(1).max(100).optional(),
});

export async function POST(request: Request) {
  try {
    const input = schema.parse(await request.json());
    return json(await loginWithPassword(input), {
      headers: { "cache-control": "no-store" },
    });
  } catch (error) {
    return problemResponse(error);
  }
}
