# Checklists operacionais

Plataforma web, API e aplicativo Flutter para inspeções semanais de veículos e equipamentos. O painel administra usuários, cadastros e modelos; o aplicativo permite preencher e cadastrar dados offline, com envio posterior ao servidor.

O catálogo de origem contém **14 modelos e 538 itens**. Isso descreve o arquivo versionado, não a quantidade de modelos atualmente existente em cada banco. Consulte [a análise da planilha](docs/spreadsheet-analysis.md).

## Documentação

| Documento                                                  | Conteúdo                                                      |
| ---------------------------------------------------------- | ------------------------------------------------------------- |
| [Aplicativo Flutter](mobile/README.md)                     | Instalação, conexão ao backend, login e testes no celular     |
| [Arquitetura](docs/architecture.md)                        | Camadas, entidades, permissões, auditoria e regras            |
| [Sincronização e limitações](docs/mobile-contract-gaps.md) | O que funciona offline e o que ainda falta                    |
| [Operação e manutenção](docs/operations.md)                | Migrações, usuários, backup, limpeza de testes e distribuição |
| [Tabelas da interface](docs/tabelas.md)                    | Componente compartilhado e estilos                            |
| [OpenAPI](openapi/openapi.yaml)                            | Rotas e estruturas da API                                     |

## Executar a plataforma localmente

Requisitos: Node.js conforme `engines` de [package.json](package.json), npm e PostgreSQL. O runtime usa `DATABASE_URL`; as migrações e scripts de manutenção preferem `DATABASE_DIRECT_URL`, quando disponível.

Na raiz do repositório:

1. Execute `npm.cmd ci`.
2. Copie `.env.example` para `.env.local` e configure as conexões, `NEXTAUTH_URL`, `NEXTAUTH_SECRET` e `AUTH_ALLOW_CREDENTIALS=true`.
3. Execute `npm.cmd run db:migrate` para aplicar as migrações pendentes.
4. **Somente para preparar um ambiente inicial ou de demonstração**, execute `npm.cmd run db:seed`.
5. Execute `npm.cmd run dev` e acesse `http://localhost:3000`.

No PowerShell, `npm.cmd` evita o bloqueio de execução que algumas máquinas aplicam a `npm.ps1`.

O seed importa o catálogo e cria dados de demonstração. O modelo VL é publicado com seus 34 itens; TE fica pendente de identificação. Não execute o seed depois de limpar dados de teste se quiser manter o banco sem esses exemplos.

## Login e administração de usuários

O acesso por credenciais usa **matrícula e senha** no painel e no aplicativo. A matrícula é texto, preserva zeros iniciais, normaliza letras para maiúsculas e deve ser única no banco.

As matrículas de demonstração para contas novas são configuradas por:

```dotenv
SEED_ADMIN_EMPLOYEE_NUMBER=000001
SEED_INSPECTOR_EMPLOYEE_NUMBER=000002
SEED_ADMIN_PASSWORD=defina-uma-senha-forte
SEED_INSPECTOR_PASSWORD=defina-outra-senha-forte
```

O seed não altera a matrícula ou a senha de contas que já existem. Após atualizar um banco antigo, use uma sessão de administrador já aberta para cadastrar a matrícula dessas contas antes de sair. Os campos `SEED_ADMIN_EMAIL` e `SEED_INSPECTOR_EMAIL` continuam no seed para identificar suas contas de demonstração; e-mail não é obrigatório no cadastro administrativo nem é o identificador do login por senha.

A página **Usuários** (`/usuarios`) é exclusiva de administradores. Ela permite cadastrar e editar nome, matrícula, perfis, senha e situação. A senha exige pelo menos 10 caracteres e até 72 bytes UTF-8. Não é permitido desativar a própria conta nem retirar o último administrador ativo.

Conta de acesso e motorista/operador do formulário são entidades distintas. A identificação do motorista não substitui o registro do usuário que preencheu a inspeção.

OIDC é uma integração opcional e usa o vínculo corporativo existente; sua configuração fica em `.env.example`.

## Funcionalidades implementadas

- Cadastros de empresas, locais, pessoas e ativos; edição e desativação no painel.
- Editor de modelos e versões, publicação, arquivamento e exclusão restrita de rascunhos sem uso.
- Semana vinculada a um ativo, modelo, versão e configuração operacional.
- Inspeções independentes por data e ocorrência, com respostas `C`, `NC`, `NA` ou vazias.
- Visão semanal, detalhes, fotos e correções com justificativa.
- Cadastros e preenchimento offline no aplicativo, com outbox transacional.
- Detecção e preservação de inspeções concorrentes no mesmo slot, com resolução explícita.
- Administração de contas e auditoria com identificação do autor.

A regra inicial usa semana iniciada na segunda-feira e fuso padrão `America/Fortaleza`, configurável no ambiente. Datas da inspeção são datas locais; instantes de auditoria são armazenados com fuso.

## Auditoria e exclusões

Novos eventos preservam `actor_user_id` e `actor_display_name`. Revisões de inspeção preservam `authored_by` e `authored_display_name`. A mudança posterior do nome não reescreve esses campos históricos.

Eventos antigos sem nome preservado podem mostrar o nome atual do cadastro, sinalizado na interface. A auditoria não equivale a um histórico de cada tecla digitada offline: ela registra as operações que chegam ao servidor.

Desativar um cadastro não o apaga. Exclusão definitiva de dados de teste é manutenção excepcional, com prévia, backup e transação. Consulte [Operação e manutenção](docs/operations.md).

## Verificações e formatação

```powershell
npm.cmd run format:check
npm.cmd run lint
npm.cmd run typecheck
npm.cmd test
npm.cmd run build
```

Para formatar o código web/API, execute `npm.cmd run format`. O padrão fica em `.prettierrc.json`; migrações, arquivos gerados e Dart ficam fora desse comando.

Os testes cobrem regras de domínio, permissões, matrícula, administração de usuários, cadastros e contratos de sincronização. No aplicativo há testes de repositório offline, reenvios, edição durante o envio, seletores e preenchimento. Esses testes não substituem a homologação em aparelhos reais.

## Estrutura

```text
src/app/                    páginas Next.js e rotas HTTP
src/features/               domínio, aplicação, infraestrutura e apresentação por funcionalidade
src/components/             navegação e componentes compartilhados
src/infrastructure/db/      cliente e esquema PostgreSQL
src/shared/                 erros, datas, hashes e apresentação da API
mobile/                     aplicativo Flutter e testes
drizzle/                    migrações versionadas
scripts/                    migração, seed e manutenção
specs/                      catálogo de origem e validação
docs/                       documentação técnica e operacional
openapi/                    contrato da API
```

## Limitações atuais

A sincronização ainda não reconstrói no celular todas as inspeções feitas em outro aparelho. A troca entre contas no mesmo dispositivo é bloqueada para proteger os dados locais. Anulação de inspeções já enviadas, assinaturas, armazenamento dedicado de fotos e exportações ainda precisam de desenvolvimento ou definição.

Antes da produção também precisam ser conferidos limite de tentativas de login, encerramento de sessões após troca de senha, assinatura release do Android, monitoramento, backup e restauração. Os detalhes estão em [Sincronização e limitações](docs/mobile-contract-gaps.md).
