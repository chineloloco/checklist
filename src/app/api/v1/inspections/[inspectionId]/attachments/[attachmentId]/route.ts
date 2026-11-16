import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { apiHandler } from "@/shared/presentation/api";

const service = new ChecklistService();
type Params = { params: Promise<{ inspectionId: string; attachmentId: string }> };

export async function GET(_request: Request, { params }: Params) {
  return apiHandler("inspections:read", async (context) => {
    const { inspectionId, attachmentId } = await params;
    const attachment = await service.getInspectionAttachment(context, inspectionId, attachmentId);
    const bytes = new Uint8Array(Buffer.from(attachment.contentBase64, "base64"));
    return new Response(bytes, {
      headers: {
        "Content-Type": attachment.mediaType,
        "Content-Length": String(bytes.byteLength),
        "Content-Disposition": `inline; filename*=UTF-8''${encodeURIComponent(attachment.fileName)}`,
        "Cache-Control": "private, max-age=300"
      }
    });
  });
}
