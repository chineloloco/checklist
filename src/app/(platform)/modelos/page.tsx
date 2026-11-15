import Link from "next/link";
import { PageHeader } from "@/components/ui/page-header";
import { Status } from "@/components/ui/status";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { TemplateService } from "@/features/templates/application/template-service";

export default async function TemplatesPage() {
  const context=await getAuthContext();const templates=await new TemplateService().list(context);
  return <><PageHeader kicker="Governança de formulários" title="Modelos de checklist" description="A redação importada da planilha permanece intacta. Toda alteração é feita em rascunho e publicada como nova versão." />
  <section className="panel"><div className="panel-header"><div><h2 className="panel-title">14 modelos importados</h2><div className="panel-subtitle">VL publicado; TE bloqueado até confirmação do nome.</div></div></div><div className="data-table-wrap"><table className="data-table"><thead><tr><th>Código</th><th>Modelo</th><th>Tipo</th><th>Versão</th><th>Publicadas</th><th>Estado</th><th></th></tr></thead><tbody>{templates.map((template)=><tr key={template.id}><td className="data-primary">{template.code}</td><td><div>{template.name??"Identificação pendente"}</div>{template.identificationStatus==="PENDING_CONFIRMATION"?<div className="data-secondary">Confirmação obrigatória antes de publicar</div>:null}</td><td>{template.assetKind==="VEHICLE"?"Veículo":"Equipamento"}</td><td className="numeric">{template.latestVersion??"—"}</td><td className="numeric">{template.publishedVersions}</td><td><Status value={template.status} label={template.status==="ACTIVE"?"Publicado":template.status==="DRAFT"?"Rascunho":"Arquivado"} /></td><td><Link className="text-link" href={`/modelos/${template.id}`}>Abrir editor</Link></td></tr>)}</tbody></table></div></section></>;
}
