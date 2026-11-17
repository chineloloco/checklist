import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it } from "vitest";
import { Tabela, type ColunaTabela } from "./tabela";

type Registro = { id: number; nome: string; ativo: boolean; local: string | null };
const dados: Registro[] = [
  { id: 1, nome: "Empresa A", ativo: true, local: null },
  { id: 2, nome: "Empresa B", ativo: false, local: "Recife" },
];
const chaveLinha = (item: Registro) => item.id;

describe("Tabela", () => {
  it.each([2, 3, 4, 5, 8])(
    "alinha cabeçalho e todas as linhas com %i colunas iguais",
    (quantidade) => {
      const colunas: ColunaTabela<Registro>[] = Array.from({ length: quantidade }, (_, index) => ({
        chave: `coluna-${index}`,
        titulo: `Coluna ${index}`,
        render: (item) => item.nome,
      }));
      const html = renderToStaticMarkup(
        <Tabela colunas={colunas} dados={dados} chaveLinha={chaveLinha} />,
      );
      const grids = [...html.matchAll(/grid-template-columns:([^";]+)/g)].map((match) => match[1]);
      expect(grids).toEqual(Array(3).fill(`repeat(${quantidade}, minmax(0, 1fr))`));
      expect(html.match(/<th\s/g)).toHaveLength(quantidade);
      expect(html.match(/<td[\s>]/g)).toHaveLength(quantidade * dados.length);
    },
  );

  it("inclui Ações na distribuição e mantém os botões em cada linha", () => {
    const html = renderToStaticMarkup(
      <Tabela
        dados={dados}
        chaveLinha={chaveLinha}
        colunas={[
          { chave: "nome", titulo: "Empresa" },
          { chave: "ativo", titulo: "Estado" },
        ]}
        acoes={(item) => (
          <>
            <button>Editar {item.nome}</button>
            <button>Desativar {item.nome}</button>
          </>
        )}
      />,
    );
    expect(html.match(/repeat\(3, minmax\(0, 1fr\)\)/g)).toHaveLength(3);
    expect(html.match(/class="tabela-acoes"/g)).toHaveLength(2);
    expect(html).toContain('class="tabela-acoes-titulo">Ações');
    expect(html).toContain("Editar Empresa A");
    expect(html).toContain("Desativar Empresa B");
  });

  it("usa as larguras excepcionais no cabeçalho e no corpo", () => {
    const html = renderToStaticMarkup(
      <Tabela
        dados={dados}
        chaveLinha={chaveLinha}
        colunas={[{ chave: "nome", titulo: "Empresa" }]}
        larguras={["2fr", "1fr"]}
        acoes={(item) => <button>{item.nome}</button>}
      />,
    );
    expect(html.match(/grid-template-columns:2fr 1fr/g)).toHaveLength(3);
  });

  it("rejeita larguras incompletas, incluindo a coluna de ações", () => {
    expect(() =>
      renderToStaticMarkup(
        <Tabela
          dados={dados}
          chaveLinha={chaveLinha}
          colunas={[{ chave: "nome", titulo: "Empresa" }]}
          larguras={["1fr"]}
          acoes={() => <button>Editar</button>}
        />,
      ),
    ).toThrow("incluindo Ações");
  });

  it("preserva valores nulos, booleanos e renderizações personalizadas", () => {
    const html = renderToStaticMarkup(
      <Tabela
        dados={dados}
        chaveLinha={chaveLinha}
        colunas={[
          { chave: "nome", titulo: "Empresa", render: (item) => <strong>{item.nome}</strong> },
          { chave: "local", titulo: "Local" },
          { chave: "ativo", titulo: "Ativo" },
        ]}
      />,
    );
    expect(html).toContain("<strong>Empresa A</strong>");
    expect(html).toContain("<td>—</td>");
    expect(html).toContain("<td>Sim</td>");
    expect(html).toContain("<td>Não</td>");
  });

  it("mantém cabeçalhos ordenáveis acessíveis e estado vazio", () => {
    const html = renderToStaticMarkup(
      <Tabela<Registro>
        dados={[]}
        chaveLinha={chaveLinha}
        legenda="Empresas"
        colunas={[
          {
            chave: "nome",
            titulo: "Empresa",
            ordenacao: "descending",
            renderTitulo: () => <button>Empresa ↓</button>,
          },
        ]}
      />,
    );
    expect(html).toContain('aria-sort="descending"');
    expect(html).toContain("<button>Empresa ↓</button>");
    expect(html).toContain("<tbody></tbody>");
    expect(html).toContain('aria-label="Empresas"');
  });
});
