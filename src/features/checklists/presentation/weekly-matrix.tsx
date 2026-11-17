import Link from "next/link";
import { Tabela } from "@/components/ui/tabela";

export type WeeklyInspectionColumn = {
  id: string;
  localDate: string;
  occurrenceNo: number;
  lifecycleStatus: string;
  conflict: boolean;
  identification: Record<string, unknown>;
  observations: string | null;
  attachments: Array<{ id: string; mediaType: "image/jpeg" | "image/png"; fileName: string }>;
};

type WeeklyView = {
  columns: WeeklyInspectionColumn[];
  sections: Array<{
    sectionId: string;
    title: string;
    items: Array<{
      itemId: string;
      sourcePrintedNumber: string | null;
      text: string;
      cells: Array<{
        inspectionId: string;
        result: "C" | "NC" | "NA" | null;
        observation: string | null;
      }>;
    }>;
  }>;
};

type MatrixItem = WeeklyView["sections"][number]["items"][number];
type MatrixRow =
  { kind: "section"; id: string; title: string } | { kind: "item"; id: string; item: MatrixItem };

export function WeeklyMatrix({ view }: { view: WeeklyView }) {
  const rows: MatrixRow[] = view.sections.flatMap((section): MatrixRow[] => [
    { kind: "section", id: section.sectionId, title: section.title },
    ...section.items.map((item): MatrixRow => ({ kind: "item", id: item.itemId, item })),
  ]);
  return (
    <Tabela<MatrixRow>
      legenda="Matriz semanal de inspeções"
      dados={rows}
      chaveLinha={(row) => row.kind + ":" + row.id}
      classeLinha={(row) => (row.kind === "section" ? "tabela-secao" : undefined)}
      colunas={[
        {
          chave: "item",
          titulo: "Item da versão publicada",
          render: (row) =>
            row.kind === "section" ? (
              row.title
            ) : (
              <>
                <span className="item-number">{row.item.sourcePrintedNumber ?? "—"}</span>
                {row.item.text}
              </>
            ),
        },
        ...view.columns.map((column) => ({
          chave: column.id,
          titulo: column.localDate,
          renderTitulo: () => (
            <Link href={"/inspecoes/" + column.id}>
              <div className="matrix-date">
                {column.localDate.slice(8, 10)}/{column.localDate.slice(5, 7)}
              </div>
              <div className="matrix-meta">
                #{column.occurrenceNo} ·{" "}
                {column.lifecycleStatus === "COMPLETED"
                  ? "concluída"
                  : column.lifecycleStatus.toLowerCase()}
                {column.conflict ? " · conflito" : ""}
              </div>
            </Link>
          ),
          render: (row: MatrixRow) => {
            if (row.kind === "section") return null;
            const cell = row.item.cells.find((candidate) => candidate.inspectionId === column.id);
            return cell?.result ? (
              <div className="matrix-cell">
                <span className={"matrix-value matrix-value-" + cell.result.toLowerCase()}>
                  {cell.result}
                </span>
                {cell.observation ? (
                  <span className="matrix-observation" title={cell.observation}>
                    {cell.observation}
                  </span>
                ) : null}
              </div>
            ) : (
              <span className="matrix-empty">—</span>
            );
          },
        })),
      ]}
    />
  );
}
