import { Tabela } from "@/components/ui/tabela";
import { AlertTriangle } from "lucide-react";
import { PageHeader } from "@/components/ui/page-header";
import { Status } from "@/components/ui/status";
import { Empty } from "@/components/ui/empty";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { ConflictService } from "@/features/conflicts/application/conflict-service";
import { ResolveConflict } from "@/features/conflicts/presentation/resolve-conflict";
import { hasPermission } from "@/features/auth/domain/permissions";

export default async function ConflictsPage() {
  const context = await getAuthContext();
  const conflicts = await new ConflictService().list(context);
  return (
    <>
      <PageHeader
        kicker="Sincronização concorrente"
        title="Conflitos"
        description="Os dois payloads permanecem guardados. Nenhuma resposta é escolhida ou descartada automaticamente."
      />
      {conflicts.length ? (
        <div style={{ display: "grid", gap: 16 }}>
          {conflicts.map((item) => (
            <section className="panel" key={item.id}>
              <div className="panel-header">
                <div>
                  <h2 className="panel-title">
                    <AlertTriangle size={17} style={{ verticalAlign: "-3px", marginRight: 7 }} />
                    Mesmo ativo, modelo, semana e data
                  </h2>
                  <div className="panel-subtitle">
                    Caso {item.id.slice(0, 8)} · {item.members.length} inspeções preservadas
                  </div>
                </div>
                <Status
                  value={item.status === "OPEN" ? "CONFLICT" : "ACTIVE"}
                  label={item.status === "OPEN" ? "Aberto" : "Resolvido"}
                />
              </div>
              <div className="panel-body">
                <Tabela
                  legenda="Inspeções em conflito"
                  dados={item.members}
                  chaveLinha={(member) => member.inspectionId}
                  colunas={[
                    {
                      chave: "inspectionId",
                      titulo: "Inspeção",
                      render: (member) => <code>{member.inspectionId}</code>,
                    },
                    { chave: "deviceId", titulo: "Dispositivo" },
                    { chave: "localDate", titulo: "Data" },
                    { chave: "occurrenceNo", titulo: "Ocorrência" },
                    { chave: "revision", titulo: "Revisão" },
                  ]}
                />
                {item.status === "OPEN" && hasPermission(context.roles, "conflicts:resolve") ? (
                  <div style={{ maxWidth: 620, marginTop: 16 }}>
                    <ResolveConflict id={item.id} revision={item.revision} members={item.members} />
                  </div>
                ) : item.reason ? (
                  <div className="notice notice-amber" style={{ marginTop: 16 }}>
                    {item.reason}
                  </div>
                ) : null}
              </div>
            </section>
          ))}
        </div>
      ) : (
        <Empty
          title="Nenhum conflito"
          description="Quando dois dispositivos criarem o mesmo slot offline, os dois registros aparecerão aqui para resolução explícita."
        />
      )}
    </>
  );
}
