import { z } from "zod";
export const resolveConflictSchema = z.object({
  resolution: z.enum(["CHOOSE_PRIMARY", "KEEP_SEPARATE", "MERGE"]),
  primaryInspectionId: z.uuid().nullable().optional(),
  reason: z.string().trim().min(3).max(2000),
  itemChoices: z.array(z.object({ itemId: z.uuid(), sourceInspectionId: z.uuid() })).optional()
});
export type ResolveConflictInput = z.infer<typeof resolveConflictSchema>;
