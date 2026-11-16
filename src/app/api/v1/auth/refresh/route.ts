import { z } from "zod";
import { rotateRefreshToken } from "@/features/auth/infrastructure/mobile-password-auth";
import { json } from "@/shared/presentation/api";
import { problemResponse } from "@/shared/presentation/problem";

const schema = z.object({
  refreshToken: z.string().min(32).max(500),
  deviceId: z.string().trim().min(1).max(100).optional()
});

export async function POST(request: Request) {
  try {
    const input = schema.parse(await request.json());
    return json(await rotateRefreshToken(input.refreshToken, input.deviceId), {
      headers: { "cache-control": "no-store" }
    });
  } catch (error) {
    return problemResponse(error);
  }
}
