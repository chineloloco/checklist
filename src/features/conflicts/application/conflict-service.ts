import type { AuthContext } from "@/features/auth/application/auth-context";
import type { ResolveConflictInput } from "@/features/conflicts/domain/conflict";
import { PostgresConflictRepository } from "@/features/conflicts/infrastructure/postgres-conflict-repository";
export class ConflictService {
  constructor(private readonly repository = new PostgresConflictRepository()) {}
  list(context: AuthContext, status?: "OPEN" | "RESOLVED") {
    return this.repository.list(context, status);
  }
  detail(context: AuthContext, id: string) {
    return this.repository.detail(context, id);
  }
  resolve(context: AuthContext, id: string, revision: number, input: ResolveConflictInput) {
    return this.repository.resolve(context, id, revision, input);
  }
}
