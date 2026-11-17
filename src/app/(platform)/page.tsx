import { Tabela } from "@/components/ui/tabela";
import Link from "next/link";
import { AlertTriangle, ArrowRight } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { ButtonLink } from "@/components/ui/button";
import { Status } from "@/components/ui/status";
import { Empty } from "@/components/ui/empty";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { TemplateService } from "@/features/templates/application/template-service";
import { ConflictService } from "@/features/conflicts/application/conflict-service";
import { mondayOf, todayInTimeZone } from "@/shared/domain/week";

export default async function DashboardPage() {
  const context = await getAuthContext();
  const timezone = process.env.DEFAULT_TIMEZONE ?? "America/Fortaleza";
  const weekStartDate = mondayOf(todayInTimeZone(timezone));
  const checklists = new ChecklistService();
  const [weekly, templates, conflicts] = await Promise.all([
    checklists.listWeekly(context, { weekStartDate }),
    new TemplateService().list(context),
    new ConflictService().list(context, "OPEN"),
  ]);
  const views = await Promise.all(
    weekly.slice(0, 20).map((item) => checklists.weeklyView(context, item.id)),
  );
  return (
    <>
      <PageHeader
        kicker=""
        title="Semana em andamento"
        description={`Início em ${weekStartDate} · ${timezone}.`}
      />
      <div className="split-grid dashboard-grid">
        <section className="panel">
          <div className="panel-header">
            <div>
              <h2 className="panel-title">Checklists desta semana</h2>
              <div className="panel-subtitle">Versão fixada na abertura de cada ativo</div>
            </div>
            <Link className="text-link" href="/checklists">
              Ver todos <ArrowRight size={14} />
            </Link>
          </div>
          {weekly.length ? (
            <Tabela
              legenda="Checklists desta semana"
              dados={weekly.slice(0, 8).map((item, index) => ({
                ...item,
                inspectionCount: views[index]?.columns.length ?? 0,
              }))}
              chaveLinha={(item) => item.id}
              colunas={[
                {
                  chave: "createdAt",
                  titulo: "Data e hora",
                  render: (item) => (
                    <time dateTime={item.createdAt.toISOString()}>
                      {new Intl.DateTimeFormat("pt-BR", {
                        timeZone: item.timezone,
                        dateStyle: "short",
                        timeStyle: "medium",
                      }).format(item.createdAt)}
                    </time>
                  ),
                },
                {
                  chave: "assetCode",
                  titulo: "Código",
                  render: (item) => <strong>{item.assetCode}</strong>,
                },
                { chave: "templateName", titulo: "Modelo" },
                { chave: "siteName", titulo: "Local" },
                { chave: "inspectionCount", titulo: "Inspeções" },
              ]}
              acoes={(item) => (
                <Link className="text-link" href={"/checklists/" + item.id}>
                  Abrir
                </Link>
              )}
            />
          ) : (
            <Empty
              title="Nenhum checklist aberto"
              description="Abra o checklist do veículo ou equipamento para fixar a versão publicada nesta semana."
            />
          )}
        </section>
        <aside style={{ display: "grid", gap: 16 }}>
          <section className="panel">
            <div className="panel-header">
              <div>
                <h2 className="panel-title">Sinais de atenção</h2>
                <div className="panel-subtitle">Sem inferências operacionais</div>
              </div>
            </div>
            <div className="panel-body" style={{ display: "grid", gap: 12 }}>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  gap: 12,
                }}
              >
                <span>Conflitos abertos</span>
                <Status
                  value={conflicts.length ? "CONFLICT" : "ACTIVE"}
                  label={String(conflicts.length)}
                />
              </div>
              {conflicts.length ? (
                <ButtonLink href="/conflitos" variant="secondary">
                  <AlertTriangle />
                  Resolver conflitos
                </ButtonLink>
              ) : null}
            </div>
          </section>
          <section className="panel">
            <div className="panel-header">
              <div>
                <h2 className="panel-title">Modelos</h2>
                <div className="panel-subtitle">{templates.length} importados da planilha</div>
              </div>
            </div>
            <div className="panel-body" style={{ display: "grid", gap: 10 }}>
              {templates.slice(0, 5).map((template) => (
                <div
                  key={template.id}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                    gap: 12,
                  }}
                >
                  <span>
                    <strong>{template.code}</strong> · {template.name ?? "Identificação pendente"}
                  </span>
                  <Status
                    value={template.status}
                    label={
                      template.status === "ACTIVE"
                        ? "Publicado"
                        : template.status === "DRAFT"
                          ? "Rascunho"
                          : "Arquivado"
                    }
                  />
                </div>
              ))}
              <Link className="text-link" href="/modelos">
                Administrar modelos <ArrowRight size={14} />
              </Link>
            </div>
          </section>
        </aside>
      </div>
    </>
  );
}
