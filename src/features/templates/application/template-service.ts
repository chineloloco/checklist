import type { AuthContext } from "@/features/auth/application/auth-context";
import type { CreateTemplateInput, UpdateTemplateVersionInput } from "@/features/templates/domain/template";
import { PostgresTemplateRepository } from "@/features/templates/infrastructure/postgres-template-repository";

export class TemplateService {
  constructor(private readonly repository = new PostgresTemplateRepository()) {}
  list(context: AuthContext, status?: "DRAFT" | "ACTIVE" | "ARCHIVED") {
    return this.repository.list(context, status);
  }
  detail(context: AuthContext, templateId: string) {
    return this.repository.detail(context, templateId);
  }
  version(context: AuthContext, versionId: string) {
    return this.repository.version(context, versionId);
  }
  create(context: AuthContext, input: CreateTemplateInput) {
    return this.repository.create(context, input);
  }
  updateDraft(context: AuthContext, versionId: string, input: UpdateTemplateVersionInput) {
    return this.repository.updateDraft(context, versionId, input);
  }
  createVersion(context: AuthContext, templateId: string, basedOnVersionId: string) {
    return this.repository.createVersion(context, templateId, basedOnVersionId);
  }
  publish(context: AuthContext, versionId: string, revision: number) {
    return this.repository.publish(context, versionId, revision);
  }
  archive(context: AuthContext, templateId: string) {
    return this.repository.archive(context, templateId);
  }
  deleteUnusedDraft(context: AuthContext, templateId: string) {
    return this.repository.deleteUnusedDraft(context, templateId);
  }
}
