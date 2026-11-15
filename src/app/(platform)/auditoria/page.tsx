import { desc, eq } from "drizzle-orm";
import { PageHeader } from "@/components/ui/page-header";
import { Empty } from "@/components/ui/empty";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { getDb } from "@/infrastructure/db/client";
import { auditEvents } from "@/infrastructure/db/schema";

export default async function AuditPage(){const context=await getAuthContext();const events=await getDb().select().from(auditEvents).where(eq(auditEvents.organizationId,context.organizationId)).orderBy(desc(auditEvents.occurredAt)).limit(200);return <><PageHeader kicker="Rastreabilidade" title="Auditoria" description="Publicações, correções, arquivamentos e resoluções são eventos append-only com autor e instante UTC." />
  <section className="panel">{events.length?<div className="data-table-wrap"><table className="data-table"><thead><tr><th>Quando</th><th>Entidade</th><th>Ação</th><th>Identificador</th><th>Motivo</th></tr></thead><tbody>{events.map((event)=><tr key={event.id}><td className="numeric">{event.occurredAt.toLocaleString("pt-BR")}</td><td>{event.entityType}</td><td className="data-primary">{event.action}</td><td><code>{event.entityId.slice(0,8)}</code></td><td>{event.reason??"—"}</td></tr>)}</tbody></table></div>:<Empty title="Sem eventos" description="Os primeiros eventos aparecerão após publicar um modelo ou registrar uma inspeção."/>}</section></>}
