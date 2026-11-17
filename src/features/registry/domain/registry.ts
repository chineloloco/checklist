import { z } from "zod";

export const registryKindSchema = z.enum(["companies", "sites", "people", "assets"]);
export type RegistryKind = z.infer<typeof registryKindSchema>;

export const createCompanySchema = z.object({
  name: z.string().trim().min(1).max(200),
  document: z.string().trim().max(30).nullable().optional(),
});
export const createSiteSchema = z.object({
  companyId: z.uuid().nullable().optional(),
  name: z.string().trim().min(1).max(200),
});
export const createPersonSchema = z.object({
  name: z.string().trim().min(1).max(200),
  kind: z.enum(["DRIVER", "OPERATOR", "SUPERVISOR"]),
  driverLicenseNumber: z.string().max(30).nullable().optional(),
  driverLicenseExpiryDate: z.iso.date().nullable().optional(),
  moppExpiryDate: z.iso.date().nullable().optional(),
  passengerCourseExpiryDate: z.iso.date().nullable().optional(),
});
export const createAssetSchema = z
  .object({
    companyId: z.uuid(),
    siteId: z.uuid().nullable().optional(),
    kind: z.enum(["VEHICLE", "EQUIPMENT"]),
    code: z.string().trim().min(1).max(100),
    licensePlate: z.string().trim().max(20).nullable().optional(),
    makeModel: z.string().trim().max(200).nullable().optional(),
    manufacturer: z.string().trim().max(200).nullable().optional(),
    manufactureYear: z.number().int().min(1900).max(2200).nullable().optional(),
    predominantColor: z.string().trim().max(80).nullable().optional(),
    ownershipType: z.enum(["OWN", "THIRD_PARTY"]),
  })
  .superRefine((value, ctx) => {
    if (value.kind === "VEHICLE" && !value.makeModel) {
      ctx.addIssue({
        code: "custom",
        path: ["makeModel"],
        message: "Informe marca e modelo do veículo.",
      });
    }
  });
export const assignTemplateSchema = z.object({
  templateId: z.uuid(),
  operationConfigId: z.uuid(),
});
