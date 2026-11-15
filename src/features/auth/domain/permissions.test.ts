import { describe, expect, it } from "vitest";
import { hasPermission } from "./permissions";
describe("role permissions",()=>{it("separates administrator and inspector powers",()=>{expect(hasPermission(["ORG_ADMIN"],"templates:publish")).toBe(true);expect(hasPermission(["INSPECTOR"],"templates:publish")).toBe(false);expect(hasPermission(["INSPECTOR"],"inspections:write")).toBe(true);expect(hasPermission(["INSPECTOR"],"conflicts:resolve")).toBe(false);});});
