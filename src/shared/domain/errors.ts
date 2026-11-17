export class DomainError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly status: number,
    public readonly details?: Record<string, unknown>,
  ) {
    super(message);
    this.name = "DomainError";
  }
}

export const notFound = (message: string) => new DomainError("NOT_FOUND", message, 404);
export const conflict = (code: string, message: string, details?: Record<string, unknown>) =>
  new DomainError(code, message, 409, details);
export const validationFailed = (message: string, errors?: unknown[]) =>
  new DomainError("VALIDATION_FAILED", message, 422, errors ? { errors } : undefined);
