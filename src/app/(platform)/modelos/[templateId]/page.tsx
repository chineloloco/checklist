import { ArrowLeft } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { ButtonLink } from "@/components/ui/button";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { TemplateService } from "@/features/templates/application/template-service";
import { TemplateEditor } from "@/features/templates/presentation/template-editor";

export default async function TemplatePage({params,searchParams}:{params:Promise<{templateId:string}>;searchParams:Promise<{version?:string}>}){
  const context=await getAuthContext();const service=new TemplateService();const detail=await service.detail(context,(await params).templateId);const query=await searchParams;const selectedId=query.version??detail.versions[0]?.id;if(!selectedId)throw new Error("Modelo sem versão.");const version=await service.version(context,selectedId);
  return <><PageHeader kicker={`${detail.code} · ${detail.assetKind==="VEHICLE"?"Veículo":"Equipamento"}`} title={detail.name??"Identificação pendente"} description="Itens usam UUID interno; a numeração impressa é mantida somente como referência de origem." actions={<ButtonLink href="/modelos" variant="secondary"><ArrowLeft />Modelos</ButtonLink>} />
  <div className="filter-bar"><div className="field"><label>Versão exibida</label><div style={{display:"flex",gap:8,flexWrap:"wrap"}}>{detail.versions.map((item)=><a className={`button ${item.id===selectedId?"button-primary":"button-secondary"}`} href={`/modelos/${detail.id}?version=${item.id}`} key={item.id}>v{item.versionNumber} · {item.status.toLowerCase()}</a>)}</div></div></div>
  <TemplateEditor version={version} /></>;
}
