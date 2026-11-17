import { Tabela } from "@/components/ui/tabela";
import { PageHeader } from "@/components/ui/page-header";
import { Empty } from "@/components/ui/empty";
import { getAuthContext, requirePermission } from "@/features/auth/application/auth-context";
import { listAuditEvents } from "@/features/audit/infrastructure/audit-query";

export default async function AuditPage() {
  const context = await getAuthContext();
  requirePermission(context, "audit:read");
  const events = await listAuditEvents(context.organizationId);
  return (
    <>
      <PageHeader
        kicker="Rastreabilidade"
        title="Auditoria"
        description="Histórico de ações com usuário, data e registro afetado. Novos eventos preservam o nome do autor no momento da ação."
      />
      <section className="panel">
        {events.length ? (
          <Tabela
            legenda="Auditoria"
            dados={events}
            chaveLinha={(event) => event.id}
            colunas={[
              {
                chave: "occurredAt",
                titulo: "Quando",
                render: (event) => event.occurredAt.toLocaleString("pt-BR"),
              },
              {
                chave: "actorDisplayName",
                titulo: "Usuário",
                render: (event) => (
                  <span title={event.actorUserId ?? "Sistema"}>
                    {event.actorDisplayName}
                    {!event.actorNamePreserved && event.actorUserId ? (
                      <small style={{ display: "block" }}>Nome do cadastro atual</small>
                    ) : null}
                  </span>
                ),
              },
              { chave: "entityType", titulo: "Entidade" },
              {
                chave: "action",
                titulo: "Ação",
                render: (event) => <strong>{event.action}</strong>,
              },
              {
                chave: "entityId",
                titulo: "Identificador",
                render: (event) => <code>{event.entityId.slice(0, 8)}</code>,
              },
              { chave: "reason", titulo: "Motivo" },
            ]}
          />
        ) : (
          <Empty
            title="Sem eventos"
            description="Os primeiros eventos aparecerão após publicar um modelo ou registrar uma inspeção."
          />
        )}
      </section>
    </>
  );
}
