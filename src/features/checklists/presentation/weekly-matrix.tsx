import Link from "next/link";
import { Fragment } from "react";

type WeeklyView = {
  columns: Array<{ id: string; localDate: string; occurrenceNo: number; lifecycleStatus: string; conflict: boolean }>;
  sections: Array<{ sectionId: string; title: string; items: Array<{ itemId: string; sourcePrintedNumber: string | null; text: string; cells: Array<{ inspectionId: string; result: "C" | "NC" | "NA" | null; observation: string | null }> }> }>;
};

export function WeeklyMatrix({ view }: { view: WeeklyView }) {
  return <div className="weekly-scroll"><table className="weekly-matrix"><thead><tr><th>Item da versão publicada</th>{view.columns.map((column) => <th key={column.id}><Link href={`/inspecoes/${column.id}`}><div className="matrix-date">{column.localDate.slice(8,10)}/{column.localDate.slice(5,7)}</div><div className="matrix-meta">#{column.occurrenceNo} · {column.lifecycleStatus === "COMPLETED" ? "concluída" : column.lifecycleStatus.toLowerCase()}{column.conflict ? " · conflito" : ""}</div></Link></th>)}</tr></thead><tbody>
    {view.sections.map((section) => <Fragment key={section.sectionId}><tr className="section-row"><td>{section.title}</td>{view.columns.map((column) => <td key={column.id}></td>)}</tr>{section.items.map((item) => <tr key={item.itemId}><td><span className="item-number">{item.sourcePrintedNumber ?? "—"}</span>{item.text}</td>{view.columns.map((column) => { const cell = item.cells.find((candidate) => candidate.inspectionId === column.id); return <td key={column.id}>{cell?.result ? <div className="matrix-cell" title={cell.observation ?? undefined}><span className={`matrix-value matrix-value-${cell.result.toLowerCase()}`}>{cell.result}</span></div> : <span className="matrix-empty">—</span>}</td>; })}</tr>)}</Fragment>)}
  </tbody></table></div>;
}
