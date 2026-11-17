import { PageHeader } from "@/components/ui/page-header";
import { WeeklyChecklistsTable } from "@/features/checklists/presentation/weekly-checklists-table";
import { Empty } from "@/components/ui/empty";
import { OpenWeeklyForm } from "@/features/checklists/presentation/open-weekly-form";
import { ChecklistAutoRefresh } from "@/features/checklists/presentation/checklist-auto-refresh";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { ChecklistService } from "@/features/checklists/application/checklist-service";
import { TemplateService } from "@/features/templates/application/template-service";
import { RegistryService } from "@/features/registry/application/registry-service";
import { todayInTimeZone } from "@/shared/domain/week";

export default async function ChecklistsPage({
  searchParams,
}: {
  searchParams: Promise<{ week?: string }>;
}) {
  const context = await getAuthContext();
  const params = await searchParams;
  const timezone = process.env.DEFAULT_TIMEZONE ?? "America/Fortaleza";
  const today = todayInTimeZone(timezone);
  const [weekly, assets, templates] = await Promise.all([
    new ChecklistService().listWeekly(context, { weekStartDate: params.week }),
    new RegistryService().listAssets(context),
    new TemplateService().list(context, "ACTIVE"),
  ]);
  return (
    <>
      <ChecklistAutoRefresh />
      <PageHeader
        kicker="Operação semanal"
        title="Checklists"
        description="Abra uma semana com a versão publicada vigente."
      />
      <OpenWeeklyForm
        initialDate={today}
        assets={assets.map((row) => ({
          id: row.asset.id,
          code: row.asset.code,
          label: row.asset.makeModel ?? row.asset.manufacturer ?? row.asset.kind,
        }))}
        templates={templates.map((item) => ({ id: item.id, code: item.code, name: item.name }))}
      />
      <section className="panel checklist-table-panel">
        <div className="panel-header">
          <div>
            <h2 className="panel-title">Semanas abertas</h2>
          </div>
        </div>
        {weekly.length ? (
          <WeeklyChecklistsTable
            items={weekly.map((item) => ({ ...item, createdAt: item.createdAt.toISOString() }))}
          />
        ) : (
          <Empty
            title="Nenhuma semana encontrada"
            description="Use os controles acima para abrir o primeiro checklist semanal do modelo de veículos leves."
          />
        )}
      </section>
    </>
  );
}
