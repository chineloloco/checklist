import { Tabela } from "@/components/ui/tabela";
import Link from "next/link";
import { Plus } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { ButtonLink } from "@/components/ui/button";
import { Status } from "@/components/ui/status";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { hasPermission } from "@/features/auth/domain/permissions";
import { TemplateService } from "@/features/templates/application/template-service";

export default async function TemplatesPage() {
  const context = await getAuthContext();
  const templates = await new TemplateService().list(context);
  return (
    <>
      <PageHeader
        kicker=""
        title="Modelos de checklist"
        description="Crie formulários ou mantenha os modelos importados. Toda alteração é feita em rascunho e publicada como nova versão."
        actions={
          hasPermission(context.roles, "templates:write") ? (
            <ButtonLink href="/modelos/novo">
              <Plus />
              Novo formulário
            </ButtonLink>
          ) : undefined
        }
      />
      <section className="panel">
        <div className="panel-header">
          <div>
            <h2 className="panel-title">{templates.length} modelos</h2>
            <div className="panel-subtitle">Formulários importados e criados pela equipe</div>
          </div>
        </div>
        <Tabela
          legenda="Modelos de checklist"
          dados={templates}
          chaveLinha={(template) => template.id}
          colunas={[
            {
              chave: "code",
              titulo: "Código",
              render: (template) => <strong>{template.code}</strong>,
            },
            {
              chave: "name",
              titulo: "Modelo",
              render: (template) => (
                <>
                  <div>{template.name ?? "Identificação pendente"}</div>
                  {template.identificationStatus === "PENDING_CONFIRMATION" ? (
                    <div className="data-secondary">Confirmação obrigatória antes de publicar</div>
                  ) : null}
                </>
              ),
            },
            {
              chave: "assetKind",
              titulo: "Tipo",
              render: (template) => (template.assetKind === "VEHICLE" ? "Veículo" : "Equipamento"),
            },
            { chave: "latestVersion", titulo: "Versão" },
            { chave: "publishedVersions", titulo: "Publicadas" },
            {
              chave: "status",
              titulo: "Estado",
              render: (template) => (
                <Status
                  value={template.status}
                  label={
                    template.status === "ACTIVE"
                      ? "Publicado"
                      : template.status === "DRAFT"
                        ? "Rascunho"
                        : "Desativado"
                  }
                />
              ),
            },
          ]}
          acoes={(template) => (
            <Link className="text-link" href={"/modelos/" + template.id}>
              {template.status === "ARCHIVED" ? "Consultar" : "Abrir editor"}
            </Link>
          )}
        />
      </section>
    </>
  );
}
