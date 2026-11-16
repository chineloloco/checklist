import { describe, expect, it } from "vitest";
import { updateInspectionSchema } from "@/features/checklists/domain/inspection";
import { syncPushSchema } from "@/features/sync/domain/sync";

describe("mobile sync contract", () => {
  it("accepts a completed inspection update with the server revision", () => {
    const operationId = "019a85c0-52f0-7000-8000-000000000001";
    const inspectionId = "019a85c0-52f0-7000-8000-000000000002";
    const itemId = "019a85c0-52f0-7000-8000-000000000003";
    const payload = {
      weeklyChecklistId: "019a85c0-52f0-7000-8000-000000000004",
      localDate: "2026-11-15",
      occurrenceNo: 1,
      lifecycleStatus: "COMPLETED",
      identification: {
        company: "Empresa Exemplo",
        site: "Pátio Norte",
        assetCode: "VL-017",
        ownershipType: "OWN",
        responsiblePersonName: "Motorista Exemplo"
      },
      observations: null,
      responses: [{ itemId, result: "C", observation: null }],
      attachments: [{
        id: "019a85c0-52f0-7000-8000-000000000005",
        mediaType: "image/jpeg",
        fileName: "evidence.jpg",
        contentBase64: "AQIDBA=="
      }]
    };

    const push = syncPushSchema.parse({
      deviceId: "flutter-test-device",
      operations: [
        {
          operationId,
          entityType: "INSPECTION",
          mutation: "COMPLETE",
          entityId: inspectionId,
          baseRevision: 1,
          clientOccurredAt: "2026-11-15T18:00:00.000Z",
          payload
        }
      ]
    });
    const update = updateInspectionSchema.parse({
      ...push.operations[0].payload,
      operationId,
      deviceId: push.deviceId,
      baseRevision: push.operations[0].baseRevision,
      lifecycleStatus: "COMPLETED"
    });

    expect(update.baseRevision).toBe(1);
    expect(update.lifecycleStatus).toBe("COMPLETED");
    expect(update.operationId).toBe(operationId);
    expect(update.attachments).toHaveLength(1);
  });
});
