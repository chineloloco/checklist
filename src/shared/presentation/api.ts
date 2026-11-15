import { NextRequest, NextResponse } from "next/server";
import { getAuthContext, requirePermission, type AuthContext } from "@/features/auth/application/auth-context";
import type { Permission } from "@/features/auth/domain/permissions";
import { problemResponse } from "@/shared/presentation/problem";
import { validationFailed } from "@/shared/domain/errors";

export async function apiHandler(
  permission: Permission,
  handler: (context: AuthContext) => Promise<Response>
): Promise<Response> {
  try {
    const context = await getAuthContext();
    requirePermission(context, permission);
    return await handler(context);
  } catch (error) {
    return problemResponse(error);
  }
}

export function json(data: unknown, init?: ResponseInit): NextResponse {
  return NextResponse.json(data, init);
}

export function requireIdempotencyKey(request: NextRequest): string {
  const value = request.headers.get("idempotency-key");
  if (!value || !/^[0-9a-f-]{36}$/i.test(value)) {
    throw validationFailed("O cabeçalho Idempotency-Key com UUID é obrigatório.");
  }
  return value;
}

export function parseIfMatch(request: NextRequest): number {
  const value = request.headers.get("if-match");
  const match = value?.match(/^"rev-(\d+)"$/);
  if (!match) throw validationFailed('O cabeçalho If-Match no formato "rev-N" é obrigatório.');
  return Number(match[1]);
}
