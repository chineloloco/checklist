"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowRight, FilePlus2 } from "lucide-react";
import { Button } from "@/components/ui/button";

const standardIdentificationFields = {
  VEHICLE: ["company", "site", "assetCode", "responsiblePersonName", "licensePlate", "vehicleMakeModel"],
  EQUIPMENT: ["company", "site", "assetCode", "responsiblePersonName", "manufacturer", "vehicleMakeModel"]
} as const;

export function TemplateCreateForm() {
  const router = useRouter();
  const [assetKind, setAssetKind] = useState<"VEHICLE" | "EQUIPMENT">("VEHICLE");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSaving(true);
    setError(null);
    const form = new FormData(event.currentTarget);
    const response = await fetch("/api/v1/templates", {
      method: "POST",
      headers: { "content-type": "application/json", "idempotency-key": crypto.randomUUID() },
      body: JSON.stringify({
        code: String(form.get("code") ?? "").trim().toUpperCase().replace(/[^A-Z0-9_]/g, "_"),
        name: String(form.get("name") ?? "").trim(),
        assetKind,
        identificationFields: [...standardIdentificationFields[assetKind]],
        sections: [{
          title: String(form.get("sectionTitle") ?? "").trim(),
          items: [{
            sourcePrintedNumber: "1",
            text: String(form.get("firstItem") ?? "").trim(),
            requiredOnComplete: true,
            requireObservationWhenNc: false,
            requirePhotoWhenNc: false
          }]
        }]
      })
    });
    const body = await response.json();
    setSaving(false);
    if (!response.ok) {
      setError(body.detail ?? "Não foi possível criar o formulário.");
      return;
    }
    router.push(`/modelos/${body.template.id}?version=${body.id}`);
    router.refresh();
  }

  return <form className="template-create-layout" onSubmit={submit}>
    <div className="template-create-main">
      <section className="panel">
        <div className="panel-header"><div><h2 className="panel-title">Dados do formulário</h2><div className="panel-subtitle">Essas informações identificam o modelo no web e no aplicativo.</div></div></div>
        <div className="panel-body form-grid">
          <div className="field"><label htmlFor="template-code">Código</label><input className="input" id="template-code" name="code" placeholder="Ex.: EMPILHADEIRA" pattern="[A-Za-z0-9_]+" maxLength={40} required /><span className="field-hint">Letras, números e sublinhado.</span></div>
          <div className="field"><label htmlFor="template-new-name">Nome do modelo</label><input className="input" id="template-new-name" name="name" placeholder="Ex.: Empilhadeira elétrica" maxLength={200} required /></div>
          <div className="field"><label htmlFor="template-kind">Tipo</label><select className="select" id="template-kind" value={assetKind} onChange={(event)=>setAssetKind(event.target.value as "VEHICLE"|"EQUIPMENT")}><option value="VEHICLE">Veículo</option><option value="EQUIPMENT">Equipamento</option></select><span className="field-hint">Empresa, local, ativo e responsável serão incluídos automaticamente.</span></div>
          <div className="field"><label htmlFor="template-section">Primeira seção</label><input className="input" id="template-section" name="sectionTitle" defaultValue="Itens de inspeção" maxLength={300} required /></div>
        </div>
      </section>
      <section className="panel">
        <div className="panel-header"><div><h2 className="panel-title">Primeiro item</h2><div className="panel-subtitle">O editor será aberto depois da criação para incluir os demais itens e regras.</div></div></div>
        <div className="panel-body"><div className="field"><label htmlFor="template-first-item">Pergunta ou item de verificação</label><textarea className="textarea" id="template-first-item" name="firstItem" placeholder="Ex.: Os pneus estão em boas condições?" maxLength={2000} required /></div></div>
      </section>
    </div>
    <aside className="template-create-actions">
      <div className="panel panel-body">
        <FilePlus2 className="template-create-icon" aria-hidden="true" />
        <h2 className="panel-title">Criar como rascunho</h2>
        <p>O formulário não ficará disponível no aplicativo até você revisar e publicar a primeira versão.</p>
        {error ? <div className="form-error" role="alert">{error}</div> : null}
        <Button type="submit" disabled={saving}><ArrowRight />{saving?"Criando…":"Criar e continuar"}</Button>
      </div>
    </aside>
  </form>;
}
