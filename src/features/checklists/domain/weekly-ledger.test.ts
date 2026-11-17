import { describe, expect, it } from "vitest";
import { WeeklyLedger } from "./weekly-ledger";

const a = { itemId: "item-1", result: "C" as const };
const nc = { itemId: "item-1", result: "NC" as const };

describe("weekly offline-first rules", () => {
  it("keeps two dates in the same week independent", () => {
    const ledger = new WeeklyLedger();
    const week = ledger.open("asset", "VL", "2026-11-10");
    ledger.create(week.id, {
      operationId: "op-1",
      clientInspectionId: "inspection-1",
      deviceId: "phone-a",
      localDate: "2026-11-10",
      occurrenceNo: 1,
      answers: [a],
    });
    ledger.create(week.id, {
      operationId: "op-2",
      clientInspectionId: "inspection-2",
      deviceId: "phone-a",
      localDate: "2026-11-12",
      occurrenceNo: 1,
      answers: [nc],
    });
    expect(week.inspections).toHaveLength(2);
    expect(week.inspections[0].answers[0].result).toBe("C");
    expect(week.inspections[1].answers[0].result).toBe("NC");
  });

  it("accepts an identical resend without duplicating", () => {
    const ledger = new WeeklyLedger();
    const week = ledger.open("asset", "VL", "2026-11-10");
    const payload = {
      operationId: "op-1",
      clientInspectionId: "inspection-1",
      deviceId: "phone-a",
      localDate: "2026-11-10",
      occurrenceNo: 1,
      answers: [a],
    };
    expect(ledger.create(week.id, payload).replayed).toBe(false);
    expect(ledger.create(week.id, payload).replayed).toBe(true);
    expect(week.inspections).toHaveLength(1);
  });

  it("preserves both offline creations for the same slot", () => {
    const ledger = new WeeklyLedger();
    const week = ledger.open("asset", "VL", "2026-11-10");
    ledger.create(week.id, {
      operationId: "op-a",
      clientInspectionId: "inspection-a",
      deviceId: "phone-a",
      localDate: "2026-11-10",
      occurrenceNo: 1,
      answers: [a],
    });
    const second = ledger.create(week.id, {
      operationId: "op-b",
      clientInspectionId: "inspection-b",
      deviceId: "phone-b",
      localDate: "2026-11-10",
      occurrenceNo: 1,
      answers: [nc],
    });
    expect(second.inspection.candidate).toBe(true);
    expect(week.inspections).toHaveLength(2);
    expect(ledger.conflicts[0].inspectionIds).toEqual(["inspection-a", "inspection-b"]);
  });

  it("fixes the published version when the week is opened", () => {
    const ledger = new WeeklyLedger();
    const oldWeek = ledger.open("asset", "VL", "2026-11-10");
    ledger.publishNextVersion();
    const newWeek = ledger.open("asset", "VL", "2026-11-17");
    expect(oldWeek.version).toBe(1);
    expect(newWeek.version).toBe(2);
  });

  it("preserves the previous revision after a correction", () => {
    const ledger = new WeeklyLedger();
    const week = ledger.open("asset", "VL", "2026-11-10");
    ledger.create(week.id, {
      operationId: "op",
      clientInspectionId: "inspection",
      deviceId: "phone",
      localDate: "2026-11-10",
      occurrenceNo: 1,
      answers: [a],
    });
    const corrected = ledger.correct(week.id, "inspection", [nc]);
    expect(corrected.revision).toBe(2);
    expect(corrected.history[0][0].result).toBe("C");
    expect(corrected.history[1][0].result).toBe("NC");
  });
});
