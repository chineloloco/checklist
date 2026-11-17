import { hashPayload } from "@/shared/infrastructure/hash";
import { mondayOf } from "@/shared/domain/week";

type Answer = { itemId: string; result: "C" | "NC" | "NA" };
type InspectionInput = {
  operationId: string;
  clientInspectionId: string;
  deviceId: string;
  localDate: string;
  occurrenceNo: number;
  answers: Answer[];
};
type InspectionRecord = InspectionInput & {
  revision: number;
  candidate: boolean;
  history: Answer[][];
};

export class WeeklyLedger {
  private publishedVersion = 1;
  private readonly weeks = new Map<
    string,
    { id: string; version: number; inspections: InspectionRecord[] }
  >();
  private readonly receipts = new Map<string, { hash: string; inspectionId: string }>();
  readonly conflicts: Array<{ slot: string; inspectionIds: string[] }> = [];

  publishNextVersion() {
    this.publishedVersion += 1;
    return this.publishedVersion;
  }

  open(assetId: string, templateId: string, localDate: string) {
    const week = mondayOf(localDate);
    const key = `${assetId}:${templateId}:${week}`;
    const existing = this.weeks.get(key);
    if (existing) return existing;
    const created = {
      id: key,
      version: this.publishedVersion,
      inspections: [] as InspectionRecord[],
    };
    this.weeks.set(key, created);
    return created;
  }

  create(weeklyId: string, input: InspectionInput) {
    const week = [...this.weeks.values()].find((candidate) => candidate.id === weeklyId);
    if (!week) throw new Error("WEEK_NOT_FOUND");
    const receiptKey = `${input.deviceId}:${input.operationId}`;
    const hash = hashPayload(input);
    const receipt = this.receipts.get(receiptKey);
    if (receipt) {
      if (receipt.hash !== hash) throw new Error("IDEMPOTENCY_KEY_REUSED");
      return {
        inspection: week.inspections.find(
          (item) => item.clientInspectionId === receipt.inspectionId,
        )!,
        replayed: true,
      };
    }
    const sameClient = week.inspections.find(
      (item) => item.clientInspectionId === input.clientInspectionId,
    );
    if (sameClient) return { inspection: sameClient, replayed: true };
    const slot = `${input.localDate}:${input.occurrenceNo}`;
    const existing = week.inspections.find(
      (item) => `${item.localDate}:${item.occurrenceNo}` === slot && !item.candidate,
    );
    const inspection: InspectionRecord = {
      ...structuredClone(input),
      revision: 1,
      candidate: Boolean(existing),
      history: [structuredClone(input.answers)],
    };
    week.inspections.push(inspection);
    this.receipts.set(receiptKey, { hash, inspectionId: input.clientInspectionId });
    if (existing)
      this.conflicts.push({
        slot,
        inspectionIds: [existing.clientInspectionId, inspection.clientInspectionId],
      });
    return { inspection, replayed: false };
  }

  correct(weeklyId: string, inspectionId: string, answers: Answer[]) {
    const week = [...this.weeks.values()].find((candidate) => candidate.id === weeklyId);
    const inspection = week?.inspections.find((item) => item.clientInspectionId === inspectionId);
    if (!inspection) throw new Error("INSPECTION_NOT_FOUND");
    inspection.answers = structuredClone(answers);
    inspection.revision += 1;
    inspection.history.push(structuredClone(answers));
    return inspection;
  }
}
