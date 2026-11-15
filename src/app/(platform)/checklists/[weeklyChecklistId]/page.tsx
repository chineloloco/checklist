import { ArrowLeft, CloudOff } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { ButtonLink } from "@/components/ui/button";
import { Status } from "@/components/ui/status";
import { WeeklyMatrix } from "@/features/checklists/presentation/weekly-matrix";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { getAuthContext } from "@/features/auth/application/auth-context";

type Params = { params: Promise<{ weeklyChecklistId: string }> };
export default async function WeeklyPage({ params }: Params) {
  const context = await getAuthContext(); const view = await new ChecklistService().weeklyView(context, (await params).weeklyChecklistId);
  const missing = view.requiredSlots.filter((slot) => !slot.fulfilled).length;
  return <>
    <PageHeader kicker="Visão semanal consolidada" title={`${view.asset.code} · ${view.asset.templateName}`} description={`${view.asset.company} · ${view.asset.site ?? "Sem local"}`} actions={<ButtonLink href="/checklists" variant="secondary"><ArrowLeft />Voltar</ButtonLink>} />
    <div className="week-context"><span>Semana: <strong>{view.weekStartDate}</strong></span><span>Fuso: <strong>{view.timezone}</strong></span><span>Inspeções recebidas: <strong>{view.columns.length}</strong></span><span>Esperadas ainda sem envio: <Status value={missing ? "DRAFT" : "ACTIVE"} label={String(missing)} /></span></div>
    <div className="notice notice-amber" style={{margin:"16px 0"}}><CloudOff /><div>Uma data esperada sem inspeção no servidor é exibida como “aguardando sincronização possível”, nunca como descumprimento confirmado.</div></div>
    <section className="panel"><WeeklyMatrix view={view} /></section>
  </>;
}
