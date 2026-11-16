import { z } from "zod";
import { revokeRefreshToken } from "@/features/auth/infrastructure/mobile-password-auth";
import { problemResponse } from "@/shared/presentation/problem";

const schema = z.object({ refreshToken: z.string().min(32).max(500) });

export async function POST(request: Request) {
  try {
    const input = schema.parse(await request.json());
    await revokeRefreshToken(input.refreshToken);
    return new Response(null, { status: 204, headers: { "cache-control": "no-store" } });
  } catch (error) {
    return problemResponse(error);
  }
}
