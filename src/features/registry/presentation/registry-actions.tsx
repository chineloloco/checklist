"use client";

import { useId, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { Pencil, Power } from "lucide-react";
import { Button } from "@/components/ui/button";
import type { RegistryKind } from "@/features/registry/domain/registry";
import type {
  RegistryCompanyChoice,
  RegistrySiteChoice,
} from "@/features/registry/domain/registry-choice";
type Field = {
  name: string;
  label: string;
  type?: string;
  required?: boolean;
  options?: [string, string][];
};
const fields: Record<RegistryKind, Field[]> = {
  companies: [
    { name: "name", label: "Nome", required: true },
    { name: "document", label: "Documento" },
  ],
  sites: [{ name: "name", label: "Nome do local", required: true }],
  people: [
    { name: "name", label: "Nome", required: true },
    {
      name: "kind",
      label: "Função",
      options: [
        ["DRIVER", "Motorista"],
        ["OPERATOR", "Operador"],
        ["SUPERVISOR", "Supervisor"],
      ],
    },
    { name: "driverLicenseNumber", label: "CNH" },
    { name: "driverLicenseExpiryDate", label: "Vencimento CNH", type: "date" },
    { name: "moppExpiryDate", label: "Vencimento MOPP", type: "date" },
    {
      name: "passengerCourseExpiryDate",
      label: "Vencimento do curso de passageiros",
      type: "date",
    },
  ],
  assets: [
    { name: "companyId", label: "Empresa", required: true },
    { name: "siteId", label: "Local" },
    {
      name: "kind",
      label: "Tipo",
      options: [
        ["VEHICLE", "Veículo"],
        ["EQUIPMENT", "Equipamento"],
      ],
    },
    { name: "code", label: "Código", required: true },
    { name: "licensePlate", label: "Placa" },
    { name: "makeModel", label: "Marca/modelo" },
    {
      name: "ownershipType",
      label: "Propriedade",
      options: [
        ["OWN", "Próprio"],
        ["THIRD_PARTY", "Terceiro"],
      ],
    },
  ],
};
const titles = {
  companies: "empresa",
  sites: "local",
  people: "pessoa",
  assets: "veículo ou equipamento",
};

export function RegistryActions({
  kind,
  record,
  companies = [],
  sites = [],
}: {
  kind: RegistryKind;
  record: Record<string, unknown> & { id: string };
  companies?: RegistryCompanyChoice[];
  sites?: RegistrySiteChoice[];
}) {
  const router = useRouter();
  const dialog = useRef<HTMLDialogElement>(null);
  const form = useRef<HTMLFormElement>(null);
  const titleId = useId();
  const [companyId, setCompanyId] = useState(String(record.companyId ?? ""));
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const name = String(record.name ?? record.code ?? "");

  async function mutate(method: "PATCH" | "DELETE", payload?: Record<string, unknown>) {
    setSaving(true);
    setError(null);
    try {
      const response = await fetch(`/api/v1/${kind}/${record.id}`, {
        method,
        headers: { "content-type": "application/json" },
        body: payload ? JSON.stringify(payload) : undefined,
      });
      if (!response.ok) {
        const problem = await response.json();
        const fieldErrors = Array.isArray(problem.errors)
          ? problem.errors.map((issue: { message: string }) => issue.message).join(" ")
          : null;
        throw new Error(fieldErrors || problem.detail || "Não foi possível salvar a alteração.");
      }
      dialog.current?.close();
      router.refresh();
    } catch (failure) {
      setError(failure instanceof Error ? failure.message : "Falha de conexão. Tente novamente.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="registry-actions">
      <Button
        variant="secondary"
        disabled={saving || record.active === false}
        aria-label={`Editar ${name}`}
        onClick={() => {
          setError(null);
          form.current?.reset();
          setCompanyId(String(record.companyId ?? ""));
          dialog.current?.showModal();
        }}
      >
        <Pencil size={14} />
      </Button>
      <Button
        variant="danger"
        disabled={saving || record.active === false}
        aria-label={`Desativar ${name}`}
        onClick={() => {
          if (
            window.confirm(
              `Desativar ${name}? O cadastro ficará indisponível para novos registros. O histórico será preservado.`,
            )
          )
            void mutate("DELETE");
        }}
      >
        <Power size={14} />
      </Button>
      {error ? (
        <span role="alert" className="form-error">
          {error}
        </span>
      ) : null}
      <dialog
        ref={dialog}
        className="registry-dialog"
        aria-labelledby={titleId}
        onCancel={(event) => {
          if (saving) event.preventDefault();
        }}
      >
        <h2 id={titleId} className="panel-title">
          Editar {titles[kind]}
        </h2>
        <form
          ref={form}
          className="form-grid"
          onSubmit={(event) => {
            event.preventDefault();
            const payload: Record<string, unknown> = Object.fromEntries(
              new FormData(event.currentTarget),
            );
            for (const field of fields[kind]) {
              if (payload[field.name] === "" && !field.required) payload[field.name] = null;
            }
            void mutate("PATCH", payload);
          }}
        >
          {fields[kind].map((field) => {
            const options =
              field.name === "companyId"
                ? companies.map((item): [string, string] => [item.id, item.name])
                : field.name === "siteId"
                  ? [
                      ["", "Sem local"] as [string, string],
                      ...sites
                        .filter((site) => !site.companyId || site.companyId === companyId)
                        .map((item): [string, string] => [item.id, item.name]),
                    ]
                  : field.options;
            const fieldId = `${titleId}-${field.name}`;
            return (
              <div className="field" key={field.name}>
                <label htmlFor={fieldId}>{field.label}</label>
                {options ? (
                  <select
                    id={fieldId}
                    key={field.name === "siteId" ? companyId : field.name}
                    name={field.name}
                    className="select"
                    required={field.required}
                    disabled={saving}
                    defaultValue={String(record[field.name] ?? "")}
                    onChange={
                      field.name === "companyId"
                        ? (event) => setCompanyId(event.target.value)
                        : undefined
                    }
                  >
                    {options.map(([value, label]) => (
                      <option value={value} key={value}>
                        {label}
                      </option>
                    ))}
                  </select>
                ) : (
                  <input
                    id={fieldId}
                    className="input"
                    name={field.name}
                    type={field.type ?? "text"}
                    required={field.required}
                    disabled={saving}
                    min={field.type === "number" ? 1900 : undefined}
                    max={field.type === "number" ? 2200 : undefined}
                    defaultValue={String(record[field.name] ?? "")}
                  />
                )}
              </div>
            );
          })}
          {error ? (
            <div className="form-error" role="alert" style={{ gridColumn: "1 / -1" }}>
              {error}
            </div>
          ) : null}
          <div className="registry-actions" style={{ gridColumn: "1 / -1" }}>
            <Button type="submit" disabled={saving}>
              {saving ? "Salvando…" : "Salvar alterações"}
            </Button>
            <Button
              type="button"
              variant="secondary"
              disabled={saving}
              onClick={() => dialog.current?.close()}
            >
              Cancelar
            </Button>
          </div>
        </form>
      </dialog>
    </div>
  );
}
