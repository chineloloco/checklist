import type { AuthContext } from "@/features/auth/application/auth-context";
import { PostgresChecklistRepository } from "@/features/checklists/infrastructure/postgres-checklist-repository";
import type {
  CreateInspectionInput,
  OpenWeeklyChecklistInput,
  UpdateInspectionInput,
} from "@/features/checklists/domain/inspection";
import {
  identificationSchema,
  inspectionAttachmentSchema,
} from "@/features/checklists/domain/inspection";
import { notFound } from "@/shared/domain/errors";

export class ChecklistService {
  constructor(private readonly repository = new PostgresChecklistRepository()) {}

  openWeekly(context: AuthContext, input: OpenWeeklyChecklistInput) {
    return this.repository.openWeekly(context, input);
  }

  createInspection(
    context: AuthContext,
    weeklyChecklistId: string,
    operationId: string,
    input: CreateInspectionInput,
  ) {
    return this.repository.createInspection(context, weeklyChecklistId, operationId, input);
  }

  updateInspection(context: AuthContext, inspectionId: string, input: UpdateInspectionInput) {
    return this.repository.updateInspection(context, inspectionId, input);
  }

  getInspection(context: AuthContext, inspectionId: string) {
    return this.repository.getInspection(context, inspectionId);
  }

  async getInspectionAttachment(context: AuthContext, inspectionId: string, attachmentId: string) {
    const inspection = await this.repository.getInspection(context, inspectionId);
    const attachments = inspectionAttachmentSchema.array().parse(inspection.attachments);
    const attachment = attachments.find((candidate) => candidate.id === attachmentId);
    if (!attachment) throw notFound("Imagem da inspeção não encontrada.");
    return attachment;
  }

  async completeInspection(context: AuthContext, inspectionId: string, baseRevision: number) {
    const current = await this.repository.getInspection(context, inspectionId);
    return this.repository.updateInspection(context, inspectionId, {
      baseRevision,
      lifecycleStatus: "COMPLETED",
      identification: identificationSchema.parse(current.identification),
      observations: current.observations,
      responses: current.responses.map((response) => ({
        itemId: response.itemId,
        result: response.result,
        observation: response.observation,
      })),
      attachments: inspectionAttachmentSchema.array().parse(current.attachments),
    });
  }

  weeklyView(context: AuthContext, weeklyChecklistId: string) {
    return this.repository.weeklyView(context, weeklyChecklistId);
  }

  listWeekly(
    context: AuthContext,
    filters: { weekStartDate?: string; assetId?: string; templateId?: string },
  ) {
    return this.repository.listWeekly(context, filters);
  }
}
