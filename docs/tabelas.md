# Tabelas da interface

Use `Tabela<T>` de `@/components/ui/tabela` em todas as listagens tabulares.
O ESLint impede criar `<table>` fora desse componente.

```tsx
import { Tabela } from "@/components/ui/tabela";
import { RegistryActions } from "@/features/registry/presentation/registry-actions";

type Empresa = { id: string; name: string; document: string | null; active: boolean };

export function Empresas({ empresas }: { empresas: Empresa[] }) {
  return (
    <Tabela<Empresa>
      legenda="Empresas"
      dados={empresas}
      chaveLinha={(empresa) => empresa.id}
      colunas={[
        { chave: "name", titulo: "Nome" },
        { chave: "document", titulo: "Documento" },
      ]}
      acoes={(empresa) => <RegistryActions kind="companies" record={empresa} />}
    />
  );
}
```

- Cabeçalho e corpo compartilham o mesmo grid. Ações conta como uma coluna.
- Por padrão, todas as colunas têm a mesma largura; a tabela preenche o container.
- A primeira coluna fica à esquerda, as demais ao centro e as ações à direita.
- Em telas pequenas, a largura mínima cresce com o número de colunas e o container permite rolagem horizontal.
- Use `render` para JSX, valores calculados, datas, campos de formulário e estados.
- Use `larguras`, por exemplo `["2fr", "1fr", "1fr"]`, apenas para exceções; inclua Ações na lista. Sua quantidade deve corresponder ao total de colunas.
- Para ordenação, use `renderTitulo` e `ordenacao` (`ascending`, `descending` ou `none`), ordenando `dados` na listagem.
- `classeLinha` permite destacar grupos, como as seções da matriz semanal.
- O componente funciona em páginas de servidor e em componentes cliente. Interações e estado ficam na listagem que o utiliza.

Os estilos ficam em `src/app/globals.css`, nas classes `tabela*`.

## Largura e espaçamento

- `.tabela-container` mantém a rolagem horizontal; evite ocultar o excesso e cortar colunas.
- `.content:has(> .dashboard-grid)` controla a largura disponível no painel inicial.
- `.dashboard-grid` controla a proporção entre a lista semanal e os painéis laterais.
- `.dashboard-grid > .panel` e `.checklist-table-panel` possuem regras específicas para o espaçamento do cabeçalho e da tabela.
- `.registry-page` contém as listas de Cadastros, organizadas em painéis expansíveis.

Para alterar somente uma tela, prefira sua classe específica. Alterar `.panel-header`, `.content` ou `.tabela td` globalmente também afeta outras páginas. Nos tamanhos menores, as regras de responsividade ficam no final do CSS.

## Componentes cliente e tipos de seleção

`Tabela` pode executar no servidor. Ordenação interativa, botões e diálogos podem ficar em componentes cliente que a utilizam. Não passe callbacks de um componente servidor diretamente para uma fronteira cliente; o componente cliente deve criar seus próprios handlers.

Os seletores de empresas e locais compartilham `RegistryCompanyChoice` e `RegistrySiteChoice`, definidos em `src/features/registry/domain/registry-choice.ts`. Um local compartilhado pode ter `companyId: null`; preserve esse tipo ao montar as opções e as props `sites`.

O padrão de formatação do projeto está em `.prettierrc.json`. Execute `npm.cmd run format` na raiz para formatar o código web/API.
