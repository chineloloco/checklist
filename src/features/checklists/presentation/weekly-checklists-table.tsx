"use client";

import { Tabela } from "@/components/ui/tabela";
import Link from "next/link";
import { useState } from "react";
import { Status } from "@/components/ui/status";

type ChecklistRow = {
  id: string;
  createdAt: string;
  timezone: string;
  assetCode: string;
  templateName: string | null;
  siteName: string | null;
  vehicleMakeModel: string | null;
};

const columns = [
  { key: "createdAt", label: "Data" },
  { key: "assetCode", label: "Código" },
  { key: "templateName", label: "Modelo" },
  { key: "vehicleMakeModel", label: "Modelo do veículo" },
  { key: "siteName", label: "Local" },
  { key: "status", label: "Estado" },
] as const;
type SortKey = (typeof columns)[number]["key"];
const collator = new Intl.Collator("pt-BR", { sensitivity: "base", numeric: true });

export function WeeklyChecklistsTable({ items }: { items: ChecklistRow[] }) {
  const [sort, setSort] = useState<{ key: SortKey; descending: boolean }>({
    key: "createdAt",
    descending: true,
  });
  const rows = [...items].sort((a, b) => {
    const value = (item: ChecklistRow) =>
      sort.key === "status" ? "Aberta" : (item[sort.key] ?? "");
    const result =
      sort.key === "createdAt"
        ? Date.parse(a.createdAt) - Date.parse(b.createdAt)
        : collator.compare(value(a), value(b));
    return (sort.descending ? -result : result) || a.id.localeCompare(b.id);
  });

  return (
    <Tabela<ChecklistRow>
      legenda="Checklists semanais"
      dados={rows}
      chaveLinha={(item) => item.id}
      colunas={columns.map(({ key, label }) => ({
        chave: key,
        titulo: label,
        ordenacao: sort.key === key ? (sort.descending ? "descending" : "ascending") : "none",
        renderTitulo: () => (
          <button
            type="button"
            className="tabela-ordenar"
            onClick={() =>
              setSort((current) => ({
                key,
                descending: current.key === key ? !current.descending : false,
              }))
            }
          >
            {label}{" "}
            <span aria-hidden="true">{sort.key === key ? (sort.descending ? "↓" : "↑") : "↕"}</span>
          </button>
        ),
        render: (item) => {
          if (key === "createdAt")
            return (
              <time dateTime={item.createdAt}>
                {new Intl.DateTimeFormat("pt-BR", {
                  timeZone: item.timezone,
                  dateStyle: "short",
                  timeStyle: "medium",
                }).format(new Date(item.createdAt))}
              </time>
            );
          if (key === "assetCode") return <strong>{item.assetCode}</strong>;
          if (key === "status") return <Status value="ACTIVE" label="Aberta" />;
          return item[key] ?? "—";
        },
      }))}
      acoes={(item) => (
        <Link className="text-link" href={"/checklists/" + item.id}>
          Visão semanal
        </Link>
      )}
    />
  );
}
