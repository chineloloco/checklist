"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Plus } from "lucide-react";
import { Button } from "@/components/ui/button";

type AssetOption = { id: string; code: string; label: string };
type TemplateOption = { id: string; code: string; name: string | null };

export function OpenWeeklyForm({
  assets,
  templates,
  initialDate,
}: {
  assets: AssetOption[];
  templates: TemplateOption[];
  initialDate: string;
}) {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setLoading(true);
    const data = new FormData(event.currentTarget);
    const response = await fetch("/api/v1/weekly-checklists", {
      method: "POST",
      headers: { "content-type": "application/json", "idempotency-key": crypto.randomUUID() },
      body: JSON.stringify({
        clientWeeklyChecklistId: crypto.randomUUID(),
        assetId: data.get("assetId"),
        templateId: data.get("templateId"),
        localDate: data.get("localDate"),
      }),
    });
    const body = await response.json();
    setLoading(false);
    if (!response.ok) {
      setError(body.detail ?? "Não foi possível abrir o checklist.");
      return;
    }
    router.push(`/checklists/${body.id}`);
    router.refresh();
  }
  return (
    <form className="filter-bar" onSubmit={submit}>
      <div className="field grow">
        <label htmlFor="assetId">Veículo ou equipamento</label>
        <select className="select" id="assetId" name="assetId" required defaultValue="">
          <option value="" disabled>
            Selecione o ativo
          </option>
          {assets.map((asset) => (
            <option key={asset.id} value={asset.id}>
              {asset.code} · {asset.label}
            </option>
          ))}
        </select>
      </div>
      <div className="field grow">
        <label htmlFor="templateId">Modelo</label>
        <select className="select" id="templateId" name="templateId" required defaultValue="">
          <option value="" disabled>
            Selecione o modelo
          </option>
          {templates.map((template) => (
            <option key={template.id} value={template.id}>
              {template.code} · {template.name}
            </option>
          ))}
        </select>
      </div>
      <div className="field">
        <label htmlFor="localDate">Data na semana</label>
        <input
          className="input"
          id="localDate"
          name="localDate"
          type="date"
          defaultValue={initialDate}
          required
        />
      </div>
      <Button disabled={loading || !assets.length || !templates.length} type="submit">
        <Plus />
        {loading ? "Abrindo…" : "Abrir semana"}
      </Button>
      {error ? (
        <div className="form-error" role="alert" style={{ width: "100%" }}>
          {error}
        </div>
      ) : null}
    </form>
  );
}
