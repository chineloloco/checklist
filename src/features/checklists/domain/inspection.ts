import { z } from "zod";

export const responseInputSchema = z.object({
  itemId: z.uuid(),
  result: z.enum(["C", "NC", "NA"]).nullable(),
  observation: z.string().max(4000).nullable().optional()
});

export const inspectionAttachmentSchema = z.object({
  id: z.uuid(),
  mediaType: z.enum(["image/jpeg", "image/png"]),
  fileName: z.string().min(1).max(255),
  contentBase64: z.string().min(1).max(3_500_000).regex(/^[A-Za-z0-9+/]+={0,2}$/)
});

export const identificationSchema = z
  .object({
    company: z.string().min(1).max(200),
    site: z.string().min(1).max(200),
    manufactureYear: z.number().int().min(1900).max(2200).nullable().optional(),
    predominantColor: z.string().max(80).nullable().optional(),
    assetCode: z.string().min(1).max(100),
    ownershipType: z.enum(["OWN", "THIRD_PARTY"]),
    licensePlate: z.string().max(20).nullable().optional(),
    vehicleMakeModel: z.string().max(200).nullable().optional(),
    manufacturer: z.string().max(200).nullable().optional(),
    responsiblePersonId: z.uuid().nullable().optional(),
    responsiblePersonName: z.string().min(1).max(200),
    driverLicenseNumber: z.string().max(30).nullable().optional(),
    driverLicenseExpiryDate: z.iso.date().nullable().optional(),
    moppExpiryDate: z.iso.date().nullable().optional(),
    passengerTransportCourseExpiryDate: z.iso.date().nullable().optional()
  })
  .passthrough();

export const openWeeklyChecklistSchema = z.object({
  clientWeeklyChecklistId: z.uuid().optional(),
  assetId: z.uuid(),
  templateId: z.uuid(),
  localDate: z.iso.date()
});

export const createInspectionSchema = z.object({
  operationId: z.uuid().optional(),
  clientInspectionId: z.uuid(),
  deviceId: z.string().min(1).max(100),
  localDate: z.iso.date(),
  occurrenceNo: z.number().int().min(1).max(20).default(1),
  lifecycleStatus: z.enum(["DRAFT", "COMPLETED"]),
  identification: identificationSchema,
  observations: z.string().max(10000).nullable().optional(),
  responses: z.array(responseInputSchema).max(500),
  attachments: z.array(inspectionAttachmentSchema).max(5).default([])
});

export const updateInspectionSchema = z.object({
  operationId: z.uuid().optional(),
  deviceId: z.string().min(1).max(100).optional(),
  baseRevision: z.number().int().min(1),
  lifecycleStatus: z.enum(["DRAFT", "COMPLETED", "CORRECTED"]).optional(),
  identification: identificationSchema,
  observations: z.string().max(10000).nullable().optional(),
  responses: z.array(responseInputSchema).max(500),
  correctionReason: z.string().min(3).max(1000).optional(),
  attachments: z.array(inspectionAttachmentSchema).max(5).default([])
});

export type OpenWeeklyChecklistInput = z.infer<typeof openWeeklyChecklistSchema>;
export type CreateInspectionInput = z.infer<typeof createInspectionSchema>;
export type UpdateInspectionInput = z.infer<typeof updateInspectionSchema>;

export type InspectionResult = {
  id: string;
  weeklyChecklistId: string;
  clientInspectionId: string;
  localDate: string;
  occurrenceNo: number;
  lifecycleStatus: "DRAFT" | "COMPLETED" | "CORRECTED" | "VOIDED";
  revision: number;
  conflictId?: string;
  conflict?: boolean;
};
