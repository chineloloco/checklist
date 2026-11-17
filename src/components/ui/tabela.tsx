import type { AriaAttributes, CSSProperties, ReactNode } from "react";

export type ColunaTabela<T> = {
  chave: keyof T | string;
  titulo: string;
  render?: (item: T) => ReactNode;
  renderTitulo?: () => ReactNode;
  ordenacao?: AriaAttributes["aria-sort"];
};

export type TabelaProps<T> = {
  colunas: ColunaTabela<T>[];
  dados: T[];
  acoes?: (item: T) => ReactNode;
  chaveLinha: (item: T) => string | number;
  /** Inclua a largura de Ações quando essa coluna estiver presente. */
  larguras?: string[];
  legenda?: string;
  classeLinha?: (item: T) => string | undefined;
};

function valorPadrao(valor: unknown): ReactNode {
  if (valor == null) return "—";
  if (typeof valor === "string" || typeof valor === "number") return valor;
  if (typeof valor === "boolean") return valor ? "Sim" : "Não";
  return String(valor);
}

/** Padrão para todas as tabelas: colunas iguais, ações e rolagem no container. */
export function Tabela<T>({
  colunas,
  dados,
  acoes,
  chaveLinha,
  larguras,
  legenda,
  classeLinha,
}: TabelaProps<T>) {
  const totalColunas = colunas.length + (acoes ? 1 : 0);
  if (!totalColunas) throw new Error("Tabela precisa de pelo menos uma coluna.");
  if (
    larguras &&
    (larguras.length !== totalColunas || larguras.some((largura) => !largura.trim()))
  ) {
    throw new Error("Informe uma largura para cada coluna, incluindo Ações.");
  }
  const grid: CSSProperties = {
    display: "grid",
    gridTemplateColumns: larguras?.join(" ") ?? `repeat(${totalColunas}, minmax(0, 1fr))`,
  };

  return (
    <div
      className="tabela-container"
      tabIndex={0}
      role="region"
      aria-label={legenda ?? "Tabela de registros"}
    >
      <table className="tabela" style={{ minWidth: Math.max(360, totalColunas * 140) }}>
        {legenda ? <caption className="sr-only">{legenda}</caption> : null}
        <thead>
          <tr style={grid}>
            {colunas.map((coluna) => (
              <th key={String(coluna.chave)} scope="col" aria-sort={coluna.ordenacao}>
                {coluna.renderTitulo ? coluna.renderTitulo() : coluna.titulo}
              </th>
            ))}
            {acoes ? (
              <th scope="col" className="tabela-acoes-titulo">
                Ações
              </th>
            ) : null}
          </tr>
        </thead>
        <tbody>
          {dados.map((item) => (
            <tr key={chaveLinha(item)} style={grid} className={classeLinha?.(item)}>
              {colunas.map((coluna) => (
                <td key={String(coluna.chave)}>
                  {coluna.render ? coluna.render(item) : valorPadrao(item[coluna.chave as keyof T])}
                </td>
              ))}
              {acoes ? <td className="tabela-acoes">{acoes(item)}</td> : null}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
