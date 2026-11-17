import { NextRequest } from "next/server";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { createInspectionSchema } from "@/features/checklists/domain/inspection";
import { apiHandler, json, requireIdempotencyKey } from "@/shared/presentation/api";

const service = new ChecklistService();
type Params = { params: Promise<{ weeklyChecklistId: string }> };

export async function POST(request: NextRequest, { params }: Params) {
  return apiHandler("inspections:write", async (context) => {
    const operationId = requireIdempotencyKey(request);
    const input = createInspectionSchema.parse(await request.json());
    const outcome = await service.createInspection(
      context,
      (await params).weeklyChecklistId,
      operationId,
      input,
    );
    if (outcome.statusCode === 409) {
      return json(
        {
          type: "/problems/duplicate-slot",
          title: "Outra inspeção ocupa o mesmo slot",
          status: 409,
          code: "DUPLICATE_SLOT",
          detail: "As duas inspeções foram preservadas para resolução explícita.",
          traceId: crypto.randomUUID(),
          conflictId: outcome.result.conflictId,
          candidateInspectionId: outcome.result.id,
        },
        { status: 409, headers: { "content-type": "application/problem+json" } },
      );
    }
    return json(outcome.result, {
      status: outcome.statusCode,
      headers: {
        Location: `/api/v1/inspections/${outcome.result.id}`,
        "Idempotency-Replayed": String(outcome.replayed),
      },
    });
  });
}
