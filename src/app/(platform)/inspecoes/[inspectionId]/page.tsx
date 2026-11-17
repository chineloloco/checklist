import { Tabela } from "@/components/ui/tabela";
import { ArrowLeft } from "lucide-react";
import { Fragment } from "react";
import { PageHeader } from "@/components/ui/page-header";
import { ButtonLink } from "@/components/ui/button";
import { Status } from "@/components/ui/status";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { hasPermission } from "@/features/auth/domain/permissions";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { CorrectionEditor } from "@/features/checklists/presentation/correction-editor";

type Params = { params: Promise<{ inspectionId: string }> };
const identificationLabels: Record<string, string> = {
  company: "Empresa",
  site: "Local",
  manufactureYear: "Ano de fabricação",
  predominantColor: "Cor predominante",
  assetCode: "Código do ativo",
  ownershipType: "Propriedade",
  licensePlate: "Placa",
  vehicleMakeModel: "Marca/modelo do veículo",
  manufacturer: "Fabricante",
  responsiblePersonName: "Motorista ou operador",
  driverLicenseNumber: "Número da CNH",
  driverLicenseExpiryDate: "Validade da CNH",
  moppExpiryDate: "Validade do MOPP",
  passengerTransportCourseExpiryDate: "Validade do curso de transporte de passageiros",
};

function identificationValue(key: string, value: unknown) {
  if (key === "ownershipType") {
    return value === "OWN" ? "Próprio" : value === "THIRD_PARTY" ? "Terceiro" : String(value);
  }
  if (
    key.endsWith("ExpiryDate") &&
    typeof value === "string" &&
    /^\d{4}-\d{2}-\d{2}$/.test(value)
  ) {
    return value.split("-").reverse().join("/");
  }
  return String(value);
}
export default async function InspectionPage({ params }: Params) {
  const context = await getAuthContext();
  const service = new ChecklistService();
  const inspection = await service.getInspection(context, (await params).inspectionId);
  const view = await service.weeklyView(context, inspection.weeklyChecklistId);
  const items = view.sections.flatMap((section) =>
    section.items.map((item) => ({
      itemId: item.itemId,
      text: item.text,
      sourcePrintedNumber: item.sourcePrintedNumber,
    })),
  );
  const answers = new Map(inspection.responses.map((answer) => [answer.itemId, answer]));
  const identity = inspection.identification as Record<string, unknown>;
  return (
    <>
      <PageHeader
        kicker="Inspeção por data"
        title={`${view.asset.code} · ${inspection.localDate}`}
        description={`Ocorrência ${inspection.occurrenceNo} · revisão ${inspection.revision}`}
        actions={
          <>
            <ButtonLink href={`/checklists/${inspection.weeklyChecklistId}`} variant="secondary">
              <ArrowLeft />
              Semana
            </ButtonLink>
            {hasPermission(context.roles, "inspections:correct") ? (
              <CorrectionEditor
                inspectionId={inspection.id}
                revision={inspection.revision}
                identification={identity}
                observations={inspection.observations}
                items={items}
                initialAnswers={inspection.responses}
              />
            ) : null}
          </>
        }
      />
      <div className="split-grid">
        <section className="panel">
          <div className="panel-header">
            <div>
              <h2 className="panel-title">Respostas</h2>
              <div className="panel-subtitle">{items.length} itens da versão fixada</div>
            </div>
            <Status
              value={inspection.lifecycleStatus}
              label={
                inspection.lifecycleStatus === "COMPLETED"
                  ? "Concluída"
                  : inspection.lifecycleStatus === "CORRECTED"
                    ? "Corrigida"
                    : "Rascunho"
              }
            />
          </div>
          <Tabela
            legenda="Respostas da inspeção"
            dados={items}
            chaveLinha={(item) => item.itemId}
            colunas={[
              {
                chave: "text",
                titulo: "Item",
                render: (item) => (
                  <>
                    <span className="item-number">{item.sourcePrintedNumber}</span>
                    {item.text}
                  </>
                ),
              },
              {
                chave: "result",
                titulo: "Resultado",
                render: (item) => {
                  const answer = answers.get(item.itemId);
                  return answer?.result ? <Status value={answer.result} /> : "—";
                },
              },
              {
                chave: "observation",
                titulo: "Observação",
                render: (item) => answers.get(item.itemId)?.observation ?? "—",
              },
            ]}
          />
        </section>
        <aside style={{ display: "grid", gap: 16 }}>
          <section className="panel">
            <div className="panel-header">
              <div>
                <h2 className="panel-title">Identificação usada</h2>
                <div className="panel-subtitle">Snapshot preservado nesta revisão</div>
              </div>
            </div>
            <div className="panel-body">
              <dl
                style={{
                  display: "grid",
                  gridTemplateColumns: "auto 1fr",
                  gap: "8px 14px",
                  margin: 0,
                }}
              >
                {Object.entries(identity)
                  .filter(
                    ([key, value]) =>
                      key !== "responsiblePersonId" && value != null && value !== "",
                  )
                  .map(([key, value]) => (
                    <Fragment key={key}>
                      <dt style={{ color: "var(--muted)" }}>{identificationLabels[key] ?? key}</dt>
                      <dd style={{ margin: 0, fontWeight: 500 }}>
                        {identificationValue(key, value)}
                      </dd>
                    </Fragment>
                  ))}
              </dl>
            </div>
          </section>
          <section className="panel">
            <div className="panel-header">
              <div>
                <h2 className="panel-title">Assinaturas</h2>
                <div className="panel-subtitle">Regra ainda não ativada</div>
              </div>
            </div>
            <div className="panel-body">
              Nenhuma assinatura é exigida até a confirmação de escopo e método de coleta.
            </div>
          </section>
          <section className="panel">
            <div className="panel-header">
              <div>
                <h2 className="panel-title">Histórico</h2>
                <div className="panel-subtitle">Revisões imutáveis</div>
              </div>
            </div>
            <div className="panel-body">
              <div className="timeline">
                {inspection.history.map((entry) => (
                  <div className="timeline-item" key={entry.revision}>
                    <div className="timeline-title">
                      Revisão {entry.revision} · {entry.status}
                    </div>
                    <div className="timeline-meta">
                      {entry.authoredDisplayName} · {entry.authoredAt.toLocaleString("pt-BR")}
                      {entry.reason ? ` · ${entry.reason}` : ""}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </section>
        </aside>
      </div>
      <div id="inspection-correction" />
    </>
  );
}
