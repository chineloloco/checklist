import { describe, expect, it } from "vitest";
import { isDateInWeek, mondayOf } from "./week";
describe("operational week", () => {
  it("starts on Monday without depending on host timezone", () => {
    expect(mondayOf("2026-11-14")).toBe("2026-11-09");
    expect(isDateInWeek("2026-11-15", "2026-11-09")).toBe(true);
    expect(isDateInWeek("2026-11-16", "2026-11-09")).toBe(false);
  });
});
