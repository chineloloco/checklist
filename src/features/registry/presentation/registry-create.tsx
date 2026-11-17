"use client";

import { useId, useState } from "react";
import { useRouter } from "next/navigation";
import { ChevronDown, Plus, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import type {
  RegistryCompanyChoice,
  RegistrySiteChoice,
} from "@/features/registry/domain/registry-choice";

type CreateRegistryKind = "company" | "site" | "person" | "asset";

type RegistryCreateProps = {
  companies: RegistryCompanyChoice[];
  sites: RegistrySiteChoice[];
};

const registryOptions: Array<{ kind: CreateRegistryKind; label: string }> = [
  { kind: "company", label: "Empresa" },
  { kind: "site", label: "Local" },
  { kind: "person", label: "Motorista ou operador" },
  { kind: "asset", label: "Veículo ou equipamento" },
];

async function postRegistry(url: string, payload: Record<string, unknown>) {
  const response = await fetch(url, {
    method: "POST",
    headers: { "content-type": "application/json", "idempotency-key": crypto.randomUUID() },
    body: JSON.stringify(payload),
  });
  const body = await response.json();
  if (!response.ok) throw new Error(body.detail ?? "Falha ao cadastrar.");
  return body;
}

function saveRegistry(kind: CreateRegistryKind, data: Record<string, FormDataEntryValue>) {
  switch (kind) {
    case "company":
      return postRegistry("/api/v1/companies", {
        name: data.name,
        document: data.document || null,
      });
    case "site":
      return postRegistry("/api/v1/sites", { name: data.name });
    case "person":
      return postRegistry("/api/v1/people", {
        name: data.name,
        kind: data.kind,
        driverLicenseNumber: data.driverLicenseNumber || null,
        driverLicenseExpiryDate: data.driverLicenseExpiryDate || null,
      });
    case "asset":
      return postRegistry("/api/v1/assets", {
        companyId: data.companyId,
        siteId: data.siteId || null,
        kind: data.kind,
        code: data.code,
        licensePlate: data.licensePlate || null,
        makeModel: data.description || null,
        ownershipType: data.ownershipType,
      });
  }
}

export function RegistryCreate({ companies, sites }: RegistryCreateProps) {
  const drawerId = useId();
  const [activeKind, setActiveKind] = useState<CreateRegistryKind | null>(null);
  const [assetCompanyId, setAssetCompanyId] = useState(companies[0]?.id ?? "");
  const router = useRouter();
  const [message, setMessage] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  function toggleDrawer(kind: CreateRegistryKind) {
    setActiveKind((current) => (current === kind ? null : kind));
    setMessage(null);
  }

  async function submit(event: React.FormEvent<HTMLFormElement>, kind: CreateRegistryKind) {
    event.preventDefault();
    setSaving(true);
    setMessage(null);
    const form = event.currentTarget;
    const data = Object.fromEntries(new FormData(form));
    try {
      await saveRegistry(kind, data);
      setMessage("Cadastro salvo.");
      form.reset();
      router.refresh();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Falha ao salvar.");
    } finally {
      setSaving(false);
    }
  }
  return (
    <section className="panel" style={{ marginBottom: 16 }}>
      <div className="panel-header">
        <div>
          <h2 className="panel-title">Novo cadastro</h2>
          <div className="panel-subtitle">
            Contas de acesso continuam separadas de motoristas e operadores.
          </div>
        </div>
      </div>
      <div className="panel-body">
        <div className="registry-create-options">
          {registryOptions.map(({ kind, label }) => (
            <Button
              key={kind}
              type="button"
              variant={activeKind === kind ? "primary" : "secondary"}
              aria-expanded={activeKind === kind}
              aria-controls={`${drawerId}-${kind}`}
              onClick={() => toggleDrawer(kind)}
            >
              {label}
              <ChevronDown className={activeKind === kind ? "registry-chevron-open" : ""} />
            </Button>
          ))}
        </div>
        <div
          id={drawerId + "-company"}
          className="registry-create-drawer"
          hidden={activeKind !== "company"}
          role="region"
          aria-label="Empresa"
        >
          <div className="registry-drawer-header">
            <h3 className="panel-title">Empresa</h3>
            <Button
              type="button"
              variant="ghost"
              aria-label="Fechar cadastro"
              onClick={() => setActiveKind(null)}
            >
              <X />
              Fechar
            </Button>
          </div>
          <form className="form-grid" onSubmit={(event) => submit(event, "company")}>
            <div className="field">
              <label>Nome</label>
              <input className="input" name="name" required />
            </div>
            <div className="field">
              <label>Documento</label>
              <input className="input" name="document" />
            </div>
            <div>
              <Button disabled={saving}>
                <Plus />
                Adicionar empresa
              </Button>
            </div>
          </form>
        </div>
        <div
          id={drawerId + "-site"}
          className="registry-create-drawer"
          hidden={activeKind !== "site"}
          role="region"
          aria-label="Local"
        >
          <div className="registry-drawer-header">
            <h3 className="panel-title">Local</h3>
            <Button
              type="button"
              variant="ghost"
              aria-label="Fechar cadastro"
              onClick={() => setActiveKind(null)}
            >
              <X />
              Fechar
            </Button>
          </div>
          <form className="form-grid" onSubmit={(event) => submit(event, "site")}>
            <div className="field">
              <label>Nome do local</label>
              <input className="input" name="name" required />
            </div>
            <div>
              <Button disabled={saving}>
                <Plus />
                Adicionar local
              </Button>
            </div>
          </form>
        </div>
        <div
          id={drawerId + "-person"}
          className="registry-create-drawer"
          hidden={activeKind !== "person"}
          role="region"
          aria-label="Motorista ou operador"
        >
          <div className="registry-drawer-header">
            <h3 className="panel-title">Motorista ou operador</h3>
            <Button
              type="button"
              variant="ghost"
              aria-label="Fechar cadastro"
              onClick={() => setActiveKind(null)}
            >
              <X />
              Fechar
            </Button>
          </div>
          <form className="form-grid" onSubmit={(event) => submit(event, "person")}>
            <div className="field">
              <label>Nome</label>
              <input className="input" name="name" required />
            </div>
            <div className="field">
              <label>Função</label>
              <select className="select" name="kind">
                <option value="DRIVER">Motorista</option>
                <option value="OPERATOR">Operador</option>
                <option value="SUPERVISOR">Supervisor</option>
              </select>
            </div>
            <div className="field">
              <label>CNH</label>
              <input className="input" name="driverLicenseNumber" />
            </div>
            <div className="field">
              <label>Vencimento CNH</label>
              <input className="input" type="date" name="driverLicenseExpiryDate" />
            </div>
            <div>
              <Button disabled={saving}>
                <Plus />
                Adicionar pessoa
              </Button>
            </div>
          </form>
        </div>
        <div
          id={drawerId + "-asset"}
          className="registry-create-drawer"
          hidden={activeKind !== "asset"}
          role="region"
          aria-label="Veículo ou equipamento"
        >
          <div className="registry-drawer-header">
            <h3 className="panel-title">Veículo ou equipamento</h3>
            <Button
              type="button"
              variant="ghost"
              aria-label="Fechar cadastro"
              onClick={() => setActiveKind(null)}
            >
              <X />
              Fechar
            </Button>
          </div>
          <form className="form-grid" onSubmit={(event) => submit(event, "asset")}>
            <div className="field">
              <label>Empresa</label>
              <select
                className="select"
                name="companyId"
                required
                value={assetCompanyId}
                onChange={(event) => setAssetCompanyId(event.target.value)}
              >
                {companies.map((item) => (
                  <option key={item.id} value={item.id}>
                    {item.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="field">
              <label>Local</label>
              <select className="select" name="siteId" key={assetCompanyId}>
                <option value="">Sem local</option>
                {sites
                  .filter((item) => !item.companyId || item.companyId === assetCompanyId)
                  .map((item) => (
                    <option key={item.id} value={item.id}>
                      {item.name}
                    </option>
                  ))}
              </select>
            </div>
            <div className="field">
              <label>Tipo</label>
              <select className="select" name="kind">
                <option value="VEHICLE">Veículo</option>
                <option value="EQUIPMENT">Equipamento</option>
              </select>
            </div>
            <div className="field">
              <label>Código</label>
              <input className="input" name="code" required />
            </div>
            <div className="field">
              <label>Placa</label>
              <input className="input" name="licensePlate" />
            </div>
            <div className="field">
              <label>Marca/modelo</label>
              <input className="input" name="description" required />
            </div>
            <div className="field">
              <label>Propriedade</label>
              <select className="select" name="ownershipType">
                <option value="OWN">Próprio</option>
                <option value="THIRD_PARTY">Terceiro</option>
              </select>
            </div>
            <div>
              <Button disabled={saving}>
                <Plus />
                Adicionar ativo
              </Button>
            </div>
          </form>
        </div>
        {message ? (
          <div className={message.includes("salvo") ? "form-success" : "form-error"}>{message}</div>
        ) : null}
      </div>
    </section>
  );
}
