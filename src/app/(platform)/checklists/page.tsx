import Link from "next/link";
import { CloudOff } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { Status } from "@/components/ui/status";
import { Empty } from "@/components/ui/empty";
import { OpenWeeklyForm } from "@/features/checklists/presentation/open-weekly-form";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { TemplateService } from "@/features/templates/application/template-service";
import { RegistryService } from "@/features/registry/application/registry-service";
import { todayInTimeZone } from "@/shared/domain/week";

export default async function ChecklistsPage({ searchParams }: { searchParams: Promise<{ week?: string }> }) {
  const context = await getAuthContext(); const params = await searchParams;
  const timezone = process.env.DEFAULT_TIMEZONE ?? "America/Fortaleza"; const today = todayInTimeZone(timezone);
  const [weekly, assets, templates] = await Promise.all([
    new ChecklistService().listWeekly(context, { weekStartDate: params.week }),
    new RegistryService().listAssets(context),
    new TemplateService().list(context, "ACTIVE")
  ]);
  return <>
    <PageHeader kicker="Operação semanal" title="Checklists" description="Abra uma semana com a versão publicada vigente. Cada data permanece independente e é disponibilizada assim que sincroniza." />
    <OpenWeeklyForm initialDate={today} assets={assets.map((row) => ({ id: row.asset.id, code: row.asset.code, label: row.asset.makeModel ?? row.asset.manufacturer ?? row.asset.kind }))} templates={templates.map((item) => ({ id: item.id, code: item.code, name: item.name }))} />
    <div className="notice notice-amber" style={{marginBottom:16}}><CloudOff /><div><strong>Calendário com incerteza offline.</strong> Somente os dias configurados são esperados. Ausência no servidor não comprova que o responsável deixou de preencher.</div></div>
    <section className="panel">
      <div className="panel-header"><div><h2 className="panel-title">Semanas abertas</h2><div className="panel-subtitle">Filtre pela data de início usando o parâmetro <code>?week=AAAA-MM-DD</code></div></div></div>
      {weekly.length ? <div className="data-table-wrap"><table className="data-table"><thead><tr><th>Semana</th><th>Ativo</th><th>Modelo</th><th>Local</th><th>Versão fixada</th><th>Estado</th><th></th></tr></thead><tbody>
        {weekly.map((item) => <tr key={item.id}><td className="numeric">{item.weekStartDate}</td><td className="data-primary">{item.assetCode}</td><td>{item.templateName}</td><td>{item.siteName ?? "—"}</td><td><code>{item.versionId.slice(0,8)}</code></td><td><Status value="ACTIVE" label="Aberta" /></td><td><Link className="text-link" href={`/checklists/${item.id}`}>Visão semanal</Link></td></tr>)}
      </tbody></table></div> : <Empty title="Nenhuma semana encontrada" description="Use os controles acima para abrir o primeiro checklist semanal do modelo de veículos leves." />}
    </section>
  </>;
}
