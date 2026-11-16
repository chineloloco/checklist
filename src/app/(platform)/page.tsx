import Link from "next/link";
import { AlertTriangle, ArrowRight, Plus } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { ButtonLink } from "@/components/ui/button";
import { Status } from "@/components/ui/status";
import { Empty } from "@/components/ui/empty";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { TemplateService } from "@/features/templates/application/template-service";
import { RegistryService } from "@/features/registry/application/registry-service";
import { ConflictService } from "@/features/conflicts/application/conflict-service";
import { mondayOf, todayInTimeZone } from "@/shared/domain/week";

export default async function DashboardPage() {
  const context = await getAuthContext();
  const timezone = process.env.DEFAULT_TIMEZONE ?? "America/Fortaleza";
  const weekStartDate = mondayOf(todayInTimeZone(timezone));
  const checklists = new ChecklistService();
  const [weekly, templates, assetRows, conflicts] = await Promise.all([
    checklists.listWeekly(context, { weekStartDate }),
    new TemplateService().list(context),
    new RegistryService().listAssets(context),
    new ConflictService().list(context, "OPEN")
  ]);
  const views = await Promise.all(weekly.slice(0, 20).map((item) => checklists.weeklyView(context, item.id)));
  const received = views.reduce((sum, view) => sum + view.columns.filter((column) => !column.conflict).length, 0);
  const expected = views.reduce((sum, view) => sum + view.requiredSlots.length, 0);
  const fulfilled = views.reduce((sum, view) => sum + view.requiredSlots.filter((slot) => slot.fulfilled).length, 0);
  const published = templates.filter((template) => template.status === "ACTIVE").length;

  return <>
    <PageHeader kicker="Visão operacional" title="Semana em andamento" description={`Início em ${weekStartDate} · ${timezone}. Datas sem envio continuam incertas enquanto houver celulares offline.`} actions={<ButtonLink href="/checklists"><Plus />Abrir checklist</ButtonLink>} />
    <div className="metric-strip">
      <div className="metric"><div className="metric-label">Inspeções recebidas</div><div className="metric-value">{received}</div><div className="metric-detail">Disponíveis sem esperar o fim da semana</div></div>
      <div className="metric"><div className="metric-label">Esperadas atendidas</div><div className="metric-value">{fulfilled}/{expected}</div><div className="metric-detail">Somente dias configurados</div></div>
      <div className="metric"><div className="metric-label">Ativos cadastrados</div><div className="metric-value">{assetRows.length}</div><div className="metric-detail">Veículos e equipamentos ativos</div></div>
      <div className="metric"><div className="metric-label">Modelos publicados</div><div className="metric-value">{published}</div><div className="metric-detail">Versões disponíveis ao aplicativo</div></div>
    </div>
    <div className="split-grid">
      <section className="panel">
        <div className="panel-header"><div><h2 className="panel-title">Checklists desta semana</h2><div className="panel-subtitle">Versão fixada na abertura de cada ativo</div></div><Link className="text-link" href="/checklists">Ver todos <ArrowRight size={14} /></Link></div>
        {weekly.length ? <div className="data-table-wrap"><table className="data-table"><thead><tr><th>Ativo</th><th>Modelo</th><th>Local</th><th>Versão</th><th>Inspeções</th><th></th></tr></thead><tbody>
          {weekly.slice(0, 8).map((item, index) => <tr key={item.id}><td><div className="data-primary">{item.assetCode}</div></td><td>{item.templateName}</td><td>{item.siteName ?? "—"}</td><td className="numeric">v{views[index]?.sections.length ? "1 fixada" : "—"}</td><td className="numeric">{views[index]?.columns.length ?? 0}</td><td><Link className="text-link" href={`/checklists/${item.id}`}>Abrir</Link></td></tr>)}
        </tbody></table></div> : <Empty title="Nenhum checklist aberto" description="Abra o checklist do veículo ou equipamento para fixar a versão publicada nesta semana." />}
      </section>
      <aside style={{display:"grid",gap:16}}>
        <section className="panel"><div className="panel-header"><div><h2 className="panel-title">Sinais de atenção</h2><div className="panel-subtitle">Sem inferências operacionais</div></div></div><div className="panel-body" style={{display:"grid",gap:12}}>
          <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",gap:12}}><span>Conflitos abertos</span><Status value={conflicts.length ? "CONFLICT" : "ACTIVE"} label={String(conflicts.length)} /></div>
          {conflicts.length ? <ButtonLink href="/conflitos" variant="secondary"><AlertTriangle />Resolver conflitos</ButtonLink> : null}
        </div></section>
        <section className="panel"><div className="panel-header"><div><h2 className="panel-title">Modelos</h2><div className="panel-subtitle">{templates.length} importados da planilha</div></div></div><div className="panel-body" style={{display:"grid",gap:10}}>
          {templates.slice(0,5).map((template) => <div key={template.id} style={{display:"flex",alignItems:"center",justifyContent:"space-between",gap:12}}><span><strong>{template.code}</strong> · {template.name ?? "Identificação pendente"}</span><Status value={template.status} label={template.status === "ACTIVE" ? "Publicado" : template.status === "DRAFT" ? "Rascunho" : "Arquivado"} /></div>)}
          <Link className="text-link" href="/modelos">Administrar modelos <ArrowRight size={14} /></Link>
        </div></section>
      </aside>
    </div>
  </>;
}
