import { NextResponse } from "next/server";
import { ZodError } from "zod";
import { AuthenticationError, AuthorizationError } from "@/features/auth/application/auth-context";
import { DomainError } from "@/shared/domain/errors";

function traceId() {
  return crypto.randomUUID();
}

export function problemResponse(error: unknown): NextResponse {
  if (error instanceof AuthenticationError) {
    return NextResponse.json(
      {
        type: "/problems/unauthorized",
        title: "Autenticação necessária",
        status: 401,
        code: "UNAUTHORIZED",
        detail: error.message,
        traceId: traceId(),
      },
      { status: 401, headers: { "content-type": "application/problem+json" } },
    );
  }
  if (error instanceof AuthorizationError) {
    return NextResponse.json(
      {
        type: "/problems/forbidden",
        title: "Acesso negado",
        status: 403,
        code: "FORBIDDEN",
        detail: error.message,
        traceId: traceId(),
      },
      { status: 403, headers: { "content-type": "application/problem+json" } },
    );
  }
  if (error instanceof ZodError) {
    return NextResponse.json(
      {
        type: "/problems/validation-failed",
        title: "Dados inválidos",
        status: 422,
        code: "VALIDATION_FAILED",
        detail: "Corrija os campos indicados.",
        traceId: traceId(),
        errors: error.issues.map((issue) => ({
          pointer: `/${issue.path.join("/")}`,
          code: issue.code,
          message: issue.message,
        })),
      },
      { status: 422, headers: { "content-type": "application/problem+json" } },
    );
  }
  if (error instanceof DomainError) {
    return NextResponse.json(
      {
        type: `/problems/${error.code.toLowerCase().replaceAll("_", "-")}`,
        title: error.message,
        status: error.status,
        code: error.code,
        detail: error.message,
        traceId: traceId(),
        ...error.details,
      },
      { status: error.status, headers: { "content-type": "application/problem+json" } },
    );
  }
  console.error(error);
  return NextResponse.json(
    {
      type: "/problems/internal",
      title: "Erro interno",
      status: 500,
      code: "INTERNAL_ERROR",
      detail: "Tente novamente.",
      traceId: traceId(),
    },
    { status: 500, headers: { "content-type": "application/problem+json" } },
  );
}
