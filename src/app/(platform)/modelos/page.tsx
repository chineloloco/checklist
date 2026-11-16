import Link from "next/link";
import { Plus } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { ButtonLink } from "@/components/ui/button";
import { Status } from "@/components/ui/status";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { hasPermission } from "@/features/auth/domain/permissions";
import { TemplateService } from "@/features/templates/application/template-service";

export default async function TemplatesPage() {
  const context=await getAuthContext();const templates=await new TemplateService().list(context);
  return <><PageHeader kicker="Governança de formulários" title="Modelos de checklist" description="Crie formulários ou mantenha os modelos importados. Toda alteração é feita em rascunho e publicada como nova versão." actions={hasPermission(context.roles,"templates:write")?<ButtonLink href="/modelos/novo"><Plus />Novo formulário</ButtonLink>:undefined} />
  <section className="panel"><div className="panel-header"><div><h2 className="panel-title">{templates.length} modelos</h2><div className="panel-subtitle">Formulários importados e criados pela equipe</div></div></div><div className="data-table-wrap"><table className="data-table"><thead><tr><th>Código</th><th>Modelo</th><th>Tipo</th><th>Versão</th><th>Publicadas</th><th>Estado</th><th></th></tr></thead><tbody>{templates.map((template)=><tr key={template.id}><td className="data-primary">{template.code}</td><td><div>{template.name??"Identificação pendente"}</div>{template.identificationStatus==="PENDING_CONFIRMATION"?<div className="data-secondary">Confirmação obrigatória antes de publicar</div>:null}</td><td>{template.assetKind==="VEHICLE"?"Veículo":"Equipamento"}</td><td className="numeric">{template.latestVersion??"—"}</td><td className="numeric">{template.publishedVersions}</td><td><Status value={template.status} label={template.status==="ACTIVE"?"Publicado":template.status==="DRAFT"?"Rascunho":"Arquivado"} /></td><td><Link className="text-link" href={`/modelos/${template.id}`}>Abrir editor</Link></td></tr>)}</tbody></table></div></section></>;
}
