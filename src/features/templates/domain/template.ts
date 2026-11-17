import { z } from "zod";

export const templateItemInputSchema = z.object({
  id: z.uuid().optional(),
  sourcePrintedNumber: z.string().max(20).nullable().optional(),
  text: z.string().trim().min(1).max(2000),
  requiredOnComplete: z.boolean().default(true),
  requireObservationWhenNc: z.boolean().default(false),
  requirePhotoWhenNc: z.boolean().default(false),
});

export const templateSectionInputSchema = z.object({
  id: z.uuid().optional(),
  title: z.string().trim().min(1).max(300),
  items: z.array(templateItemInputSchema).min(1).max(500),
});

export const createTemplateSchema = z.object({
  code: z
    .string()
    .trim()
    .min(1)
    .max(40)
    .regex(/^[A-Z0-9_]+$/),
  name: z.string().trim().min(1).max(200).nullable(),
  assetKind: z.enum(["VEHICLE", "EQUIPMENT"]),
  identificationFields: z.array(z.string().min(1).max(80)).min(1).max(50),
  sections: z.array(templateSectionInputSchema).min(1).max(50),
});

export const updateTemplateVersionSchema = z.object({
  identificationFields: z.array(z.string().min(1).max(80)).min(1).max(50),
  sections: z.array(templateSectionInputSchema).min(1).max(50),
  baseRevision: z.number().int().min(1),
});

export const updateTemplateMetadataSchema = z.object({
  name: z.string().trim().min(2).max(200),
});

export type CreateTemplateInput = z.infer<typeof createTemplateSchema>;
export type UpdateTemplateVersionInput = z.infer<typeof updateTemplateVersionSchema>;
export type UpdateTemplateMetadataInput = z.infer<typeof updateTemplateMetadataSchema>;
