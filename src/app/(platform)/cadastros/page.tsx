import { Tabela } from "@/components/ui/tabela";
import { ChevronDown } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { RegistryActions } from "@/features/registry/presentation/registry-actions";
import { Status } from "@/components/ui/status";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { hasPermission } from "@/features/auth/domain/permissions";
import { RegistryService } from "@/features/registry/application/registry-service";
import { RegistryCreate } from "@/features/registry/presentation/registry-create";
import type {
  RegistryCompanyChoice,
  RegistrySiteChoice,
} from "@/features/registry/domain/registry-choice";

const personKindLabels: Record<string, string> = {
  DRIVER: "Motorista",
  OPERATOR: "Operador",
  SUPERVISOR: "Supervisor",
};

function activeFirst(left: { active: boolean }, right: { active: boolean }) {
  return Number(right.active) - Number(left.active);
}

export default async function RegistryPage() {
  const context = await getAuthContext();
  const service = new RegistryService();
  const [companyRows, siteRows, people, assetRows] = await Promise.all([
    service.listCompanies(context),
    service.listSites(context),
    service.listPeople(context, true),
    service.listAssets(context),
  ]);
  const companies = companyRows.filter((item) => item.active);
  const sites = siteRows.filter((item) => item.active);
  const sortedSites = [...siteRows].sort(activeFirst);
  const sortedPeople = [...people].sort(activeFirst);
  const assets = [...assetRows].sort((left, right) => activeFirst(left.asset, right.asset));
  const activeAssetCount = assets.filter(({ asset }) => asset.active).length;
  const activePersonCount = people.filter((person) => person.active).length;
  const canWrite = hasPermission(context.roles, "cadastros:write");
  const companyChoices: RegistryCompanyChoice[] = companies.map(({ id, name }) => ({ id, name }));
  const siteChoices: RegistrySiteChoice[] = sites.map(({ id, name, companyId }) => ({
    id,
    name,
    companyId,
  }));
  return (
    <div className="registry-page">
      <PageHeader
        kicker="Base operacional"
        title="Cadastros"
        description="Alterações futuras não reescrevem os snapshots usados nas inspeções anteriores."
      />
      {canWrite ? <RegistryCreate companies={companyChoices} sites={siteChoices} /> : null}
      <div style={{ display: "grid", gap: 20 }}>
        <details className="panel registry-list-drawer" open>
          <summary className="panel-header">
            <div>
              <h2 className="panel-title">Veículos e equipamentos</h2>
              <div className="panel-subtitle">
                {activeAssetCount} ativos · {assets.length - activeAssetCount} desativados
              </div>
            </div>
            <ChevronDown className="registry-list-chevron" aria-hidden="true" />
          </summary>
          <Tabela
            legenda="Veículos e equipamentos"
            dados={assets}
            chaveLinha={({ asset }) => asset.id}
            colunas={[
              {
                chave: "code",
                titulo: "Código",
                render: ({ asset }) => <strong>{asset.code}</strong>,
              },
              {
                chave: "kind",
                titulo: "Tipo",
                render: ({ asset }) => (asset.kind === "VEHICLE" ? "Veículo" : "Equipamento"),
              },
              {
                chave: "identification",
                titulo: "Identificação",
                render: ({ asset }) =>
                  asset.licensePlate ?? asset.makeModel ?? asset.manufacturer ?? "—",
              },
              { chave: "siteName", titulo: "Local" },
              {
                chave: "ownershipType",
                titulo: "Propriedade",
                render: ({ asset }) => (asset.ownershipType === "OWN" ? "Próprio" : "Terceiro"),
              },
              {
                chave: "active",
                titulo: "Estado",
                render: ({ asset }) => (
                  <Status
                    value={asset.active ? "ACTIVE" : "ARCHIVED"}
                    label={asset.active ? "Ativo" : "Desativado"}
                  />
                ),
              },
            ]}
            acoes={
              canWrite
                ? ({ asset }) => (
                    <RegistryActions
                      kind="assets"
                      record={asset}
                      companies={companyChoices}
                      sites={siteChoices}
                    />
                  )
                : undefined
            }
          />
        </details>
        <details className="panel registry-list-drawer" open>
          <summary className="panel-header">
            <div>
              <h2 className="panel-title">Locais</h2>
              <div className="panel-subtitle">
                {sites.length} ativos · {siteRows.length - sites.length} desativados
              </div>
            </div>
            <ChevronDown className="registry-list-chevron" aria-hidden="true" />
          </summary>
          <Tabela
            legenda="Locais"
            dados={sortedSites}
            chaveLinha={(site) => site.id}
            colunas={[
              { chave: "name", titulo: "Nome", render: (site) => <strong>{site.name}</strong> },
              {
                chave: "active",
                titulo: "Estado",
                render: (site) => (
                  <Status
                    value={site.active ? "ACTIVE" : "ARCHIVED"}
                    label={site.active ? "Ativo" : "Desativado"}
                  />
                ),
              },
            ]}
            acoes={canWrite ? (site) => <RegistryActions kind="sites" record={site} /> : undefined}
          />
        </details>
        <details className="panel registry-list-drawer" open>
          <summary className="panel-header">
            <div>
              <h2 className="panel-title">Motoristas e operadores</h2>
              <div className="panel-subtitle">
                {activePersonCount} ativos · {people.length - activePersonCount} desativados
              </div>
            </div>
            <ChevronDown className="registry-list-chevron" aria-hidden="true" />
          </summary>
          <Tabela
            legenda="Motoristas e operadores"
            dados={sortedPeople}
            chaveLinha={(person) => person.id}
            colunas={[
              { chave: "name", titulo: "Nome", render: (person) => <strong>{person.name}</strong> },
              {
                chave: "kind",
                titulo: "Função",
                render: (person) => personKindLabels[person.kind],
              },
              { chave: "driverLicenseNumber", titulo: "CNH" },
              {
                chave: "driverLicenseExpiryDate",
                titulo: "Vencimento CNH",
                render: (person) =>
                  person.driverLicenseExpiryDate?.split("-").reverse().join("/") ?? "—",
              },
              {
                chave: "active",
                titulo: "Estado",
                render: (person) => (
                  <Status
                    value={person.active ? "ACTIVE" : "ARCHIVED"}
                    label={person.active ? "Ativo" : "Desativado"}
                  />
                ),
              },
            ]}
            acoes={
              canWrite ? (person) => <RegistryActions kind="people" record={person} /> : undefined
            }
          />
        </details>
        <details className="panel registry-list-drawer" open>
          <summary className="panel-header">
            <div>
              <h2 className="panel-title">Empresas</h2>
              <div className="panel-subtitle">{companies.length} ativas</div>
            </div>
            <ChevronDown className="registry-list-chevron" aria-hidden="true" />
          </summary>
          <Tabela
            legenda="Empresas"
            dados={companies}
            chaveLinha={(company) => company.id}
            colunas={[
              {
                chave: "name",
                titulo: "Nome",
                render: (company) => <strong>{company.name}</strong>,
              },
              { chave: "document", titulo: "Documento" },
            ]}
            acoes={
              canWrite
                ? (company) => <RegistryActions kind="companies" record={company} />
                : undefined
            }
          />
        </details>
      </div>
    </div>
  );
}
