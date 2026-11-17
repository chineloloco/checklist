"use client";
import { Tabela } from "@/components/ui/tabela";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { CheckCircle2, CopyPlus, Plus, Save, Send, Power, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";

type Item = {
  id: string;
  sourcePrintedNumber: string | null;
  originalText: string;
  requiredOnComplete: boolean;
  requireObservationWhenNc: boolean;
  requirePhotoWhenNc: boolean;
};
type Section = { id: string; title: string; items: Item[] };
type Version = {
  id: string;
  templateId: string;
  versionNumber: number;
  status: "DRAFT" | "PUBLISHED" | "ARCHIVED";
  revision: number;
  identificationFields: string[];
  sections: Section[];
};

export function TemplateEditor({
  version,
  templateName,
  identificationStatus,
  canDelete,
  inactive = false,
}: {
  version: Version;
  templateName: string | null;
  identificationStatus: string;
  canDelete: boolean;
  inactive?: boolean;
}) {
  const router = useRouter();
  const editable = !inactive && version.status === "DRAFT";
  const [sections, setSections] = useState(version.sections);
  const [name, setName] = useState(templateName ?? "");
  const [confirmed, setConfirmed] = useState(
    identificationStatus !== "PENDING_CONFIRMATION" && Boolean(templateName),
  );
  const [message, setMessage] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const itemCount = useMemo(
    () => sections.reduce((sum, section) => sum + section.items.length, 0),
    [sections],
  );
  function updateItem(sectionId: string, itemId: string, text: string) {
    setSections((current) =>
      current.map((section) =>
        section.id === sectionId
          ? {
              ...section,
              items: section.items.map((item) =>
                item.id === itemId ? { ...item, originalText: text } : item,
              ),
            }
          : section,
      ),
    );
  }
  function addItem(sectionId: string) {
    setSections((current) =>
      current.map((section) =>
        section.id === sectionId
          ? {
              ...section,
              items: [
                ...section.items,
                {
                  id: crypto.randomUUID(),
                  sourcePrintedNumber: null,
                  originalText: "",
                  requiredOnComplete: true,
                  requireObservationWhenNc: false,
                  requirePhotoWhenNc: false,
                },
              ],
            }
          : section,
      ),
    );
  }
  function removeItem(sectionId: string, itemId: string) {
    setSections((current) =>
      current.map((section) =>
        section.id === sectionId
          ? { ...section, items: section.items.filter((item) => item.id !== itemId) }
          : section,
      ),
    );
  }
  function addSection() {
    setSections((current) => [
      ...current,
      { id: crypto.randomUUID(), title: "Nova seção", items: [] },
    ]);
  }
  async function save() {
    setSaving(true);
    setMessage(null);
    const response = await fetch(`/api/v1/template-versions/${version.id}`, {
      method: "PATCH",
      headers: { "content-type": "application/json", "if-match": `"rev-${version.revision}"` },
      body: JSON.stringify({
        identificationFields: version.identificationFields,
        sections: sections.map((section) => ({
          id: section.id,
          title: section.title,
          items: section.items.map((item) => ({
            id: item.id,
            sourcePrintedNumber: item.sourcePrintedNumber,
            text: item.originalText,
            requiredOnComplete: item.requiredOnComplete,
            requireObservationWhenNc: item.requireObservationWhenNc,
            requirePhotoWhenNc: item.requirePhotoWhenNc,
          })),
        })),
      }),
    });
    const body = await response.json();
    setSaving(false);
    if (!response.ok) {
      setMessage(body.detail ?? "Falha ao salvar.");
      return;
    }
    setMessage("Rascunho salvo.");
    router.refresh();
  }
  async function confirmIdentification() {
    setSaving(true);
    setMessage(null);
    const response = await fetch(`/api/v1/templates/${version.templateId}`, {
      method: "PATCH",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ name }),
    });
    const body = await response.json();
    setSaving(false);
    if (!response.ok) {
      setMessage(body.detail ?? "Falha ao confirmar a identificação.");
      return;
    }
    setName(body.name);
    setConfirmed(true);
    setMessage("Identificação confirmada. O modelo já pode ser publicado.");
    router.refresh();
  }
  async function deactivateTemplate() {
    if (
      !window.confirm(
        "Desativar este formulário? As versões, os itens e o histórico serão preservados.",
      )
    )
      return;
    setSaving(true);
    setMessage(null);
    try {
      const response = await fetch(`/api/v1/templates/${version.templateId}/archive`, {
        method: "POST",
      });
      if (!response.ok) {
        const body = await response.json();
        setMessage(body.detail ?? "Não foi possível desativar o formulário.");
        return;
      }
      router.push("/modelos");
      router.refresh();
    } catch {
      setMessage("Falha de conexão. Tente novamente.");
    } finally {
      setSaving(false);
    }
  }
  async function publish() {
    setSaving(true);
    setMessage(null);
    const response = await fetch(`/api/v1/template-versions/${version.id}/publish`, {
      method: "POST",
      headers: { "if-match": `"rev-${version.revision}"`, "idempotency-key": crypto.randomUUID() },
    });
    const body = await response.json();
    setSaving(false);
    if (!response.ok) {
      setMessage(body.detail ?? "Falha ao publicar.");
      return;
    }
    router.refresh();
  }
  async function newVersion() {
    setSaving(true);
    const response = await fetch(`/api/v1/templates/${version.templateId}/versions`, {
      method: "POST",
      headers: { "content-type": "application/json", "idempotency-key": crypto.randomUUID() },
      body: JSON.stringify({ basedOnVersionId: version.id }),
    });
    const body = await response.json();
    setSaving(false);
    if (!response.ok) {
      setMessage(body.detail ?? "Falha ao criar versão.");
      return;
    }
    router.push(`/modelos/${version.templateId}?version=${body.id}`);
    router.refresh();
  }
  return (
    <>
      {inactive ? (
        <div className="form-error" role="status">
          Formulário desativado. Os itens e o histórico estão preservados para consulta.
        </div>
      ) : null}
      <section
        className={`panel template-identification ${confirmed ? "template-identification-confirmed" : "template-identification-pending"}`}
      >
        <div className="panel-header">
          <div>
            <h2 className="panel-title">Identificação do modelo</h2>
            <div className="panel-subtitle">
              {confirmed
                ? "Nome confirmado para publicação e uso no aplicativo."
                : "Informe qual equipamento este checklist representa para liberar a publicação."}
            </div>
          </div>
          {confirmed ? (
            <span className="template-confirmed-label">
              <CheckCircle2 /> Confirmada
            </span>
          ) : null}
        </div>
        <div className="panel-body template-identification-form">
          <div className="field grow">
            <label htmlFor="template-name">Nome do modelo</label>
            <input
              className="input"
              id="template-name"
              disabled={inactive}
              value={name}
              onChange={(event) => {
                setName(event.target.value);
                setConfirmed(false);
              }}
              placeholder="Ex.: Trator de esteira"
              maxLength={200}
            />
          </div>
          <Button
            variant={confirmed ? "secondary" : "primary"}
            onClick={confirmIdentification}
            disabled={inactive || saving || name.trim().length < 2}
          >
            <CheckCircle2 />
            {confirmed ? "Salvar nome" : "Confirmar identificação"}
          </Button>
        </div>
      </section>
      <div className="filter-bar" style={{ justifyContent: "space-between" }}>
        <div>
          <strong>Versão {version.versionNumber}</strong> · {itemCount} itens ·{" "}
          <span style={{ color: "var(--muted)" }}>{version.status}</span>
        </div>
        <div className="template-editor-actions">
          {canDelete ? (
            <Button variant="danger" disabled={saving} onClick={deactivateTemplate}>
              <Power />
              Desativar formulário
            </Button>
          ) : null}
          {editable ? (
            <>
              <Button variant="secondary" onClick={addSection}>
                <Plus />
                Seção
              </Button>
              <Button variant="secondary" onClick={save} disabled={saving}>
                <Save />
                Salvar
              </Button>
              <Button
                onClick={publish}
                disabled={saving || !confirmed}
                title={!confirmed ? "Confirme o nome do modelo antes de publicar." : undefined}
              >
                <Send />
                Publicar
              </Button>
            </>
          ) : (
            <Button onClick={newVersion} disabled={inactive || saving}>
              <CopyPlus />
              Criar nova versão
            </Button>
          )}
        </div>
        {message ? (
          <div
            className={
              message.includes("salvo") || message.includes("confirmada")
                ? "form-success"
                : "form-error"
            }
            style={{ width: "100%" }}
          >
            {message}
          </div>
        ) : null}
        {editable && !confirmed ? (
          <div className="form-error" style={{ width: "100%" }}>
            Confirme a identificação acima para habilitar a publicação.
          </div>
        ) : null}
      </div>
      <div style={{ display: "grid", gap: 16 }}>
        {sections.map((section) => (
          <section className="panel" key={section.id}>
            <div className="panel-header">
              <div className="field grow">
                <label>Seção</label>
                <input
                  className="input"
                  value={section.title}
                  disabled={!editable}
                  onChange={(event) =>
                    setSections((current) =>
                      current.map((item) =>
                        item.id === section.id ? { ...item, title: event.target.value } : item,
                      ),
                    )
                  }
                />
              </div>
              {editable ? (
                <Button variant="secondary" onClick={() => addItem(section.id)}>
                  <Plus />
                  Item
                </Button>
              ) : null}
            </div>
            <Tabela
              legenda={section.title}
              dados={section.items}
              chaveLinha={(item) => item.id}
              colunas={[
                {
                  chave: "sourcePrintedNumber",
                  titulo: "Nº origem",
                  render: (item) => (
                    <input
                      aria-label="Número de origem"
                      className="input"
                      value={item.sourcePrintedNumber ?? ""}
                      disabled={!editable}
                      onChange={(event) =>
                        setSections((current) =>
                          current.map((candidate) =>
                            candidate.id === section.id
                              ? {
                                  ...candidate,
                                  items: candidate.items.map((currentItem) =>
                                    currentItem.id === item.id
                                      ? { ...currentItem, sourcePrintedNumber: event.target.value }
                                      : currentItem,
                                  ),
                                }
                              : candidate,
                          ),
                        )
                      }
                    />
                  ),
                },
                {
                  chave: "originalText",
                  titulo: "Redação do item",
                  render: (item) => (
                    <textarea
                      aria-label="Redação do item"
                      className="textarea"
                      style={{ minHeight: 58 }}
                      value={item.originalText}
                      disabled={!editable}
                      onChange={(event) => updateItem(section.id, item.id, event.target.value)}
                    />
                  ),
                },
                {
                  chave: "requiredOnComplete",
                  titulo: "Obrigatório",
                  render: (item) => (
                    <input
                      aria-label="Item obrigatório"
                      type="checkbox"
                      checked={item.requiredOnComplete}
                      disabled={!editable}
                      onChange={(event) =>
                        setSections((current) =>
                          current.map((candidate) =>
                            candidate.id === section.id
                              ? {
                                  ...candidate,
                                  items: candidate.items.map((currentItem) =>
                                    currentItem.id === item.id
                                      ? { ...currentItem, requiredOnComplete: event.target.checked }
                                      : currentItem,
                                  ),
                                }
                              : candidate,
                          ),
                        )
                      }
                    />
                  ),
                },
                {
                  chave: "requireObservationWhenNc",
                  titulo: "NC exige observação",
                  render: (item) => (
                    <input
                      aria-label="NC exige observação"
                      type="checkbox"
                      checked={item.requireObservationWhenNc}
                      disabled={!editable}
                      onChange={(event) =>
                        setSections((current) =>
                          current.map((candidate) =>
                            candidate.id === section.id
                              ? {
                                  ...candidate,
                                  items: candidate.items.map((currentItem) =>
                                    currentItem.id === item.id
                                      ? {
                                          ...currentItem,
                                          requireObservationWhenNc: event.target.checked,
                                        }
                                      : currentItem,
                                  ),
                                }
                              : candidate,
                          ),
                        )
                      }
                    />
                  ),
                },
              ]}
              acoes={
                editable
                  ? (item) => (
                      <button
                        aria-label="Apagar pergunta"
                        className="button button-ghost"
                        type="button"
                        title="Apagar pergunta"
                        onClick={() => removeItem(section.id, item.id)}
                      >
                        <Trash2 />
                      </button>
                    )
                  : undefined
              }
            />
          </section>
        ))}
      </div>
    </>
  );
}
