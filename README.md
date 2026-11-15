# Checklists operacionais

Plataforma web e API para checklists semanais de veículos e equipamentos. O núcleo implementado usa Next.js 16, TypeScript, PostgreSQL/Neon, Drizzle ORM e autenticação OIDC/NextAuth. A estrutura separa apresentação, rotas HTTP, serviços de aplicação, regras de domínio e repositórios por funcionalidade.

O catálogo inicial foi extraído da planilha `MODELOS DE CHECK LIST.xlsx`: são 14 modelos e 538 itens com a redação preservada. O modelo **VL — Veículos leves** é publicado pelo seed com seus 34 itens reais. O modelo **TE** permanece identificado como pendente de confirmação.

## Executar localmente

Requisitos: Node.js 20.9 ou superior e um banco PostgreSQL 15 ou superior. Para produção, use as URLs pooled e direct fornecidas pelo Neon.

1. Instale as dependências:

   ```powershell
   npm install
   ```

2. Copie `.env.example` para `.env.local` e preencha `DATABASE_URL`, `DATABASE_DIRECT_URL` e `NEXTAUTH_SECRET`.

3. Crie o esquema e carregue o catálogo:

   ```powershell
   npm run db:migrate
   npm run db:seed
   ```

4. Inicie a aplicação:

   ```powershell
   npm run dev
   ```

5. Acesse `http://localhost:3000`. Com `AUTH_ALLOW_CREDENTIALS=true`, o seed cria somente para desenvolvimento:

   - administrador: `admin@checklist.local`
   - responsável: `responsavel@checklist.local`
   - senhas: os valores definidos em `SEED_ADMIN_PASSWORD` e `SEED_INSPECTOR_PASSWORD`

Credenciais locais são bloqueadas em produção. Configure `OIDC_ISSUER`, `OIDC_CLIENT_ID` e `OIDC_CLIENT_SECRET` para o provedor corporativo.

## Verificação

```powershell
npm run typecheck
npm run lint
npm test
npm run build
```

Os testes automatizados cobrem o recorte VL solicitado: duas datas na mesma semana com respostas independentes, reenvio idêntico sem duplicação, criação concorrente por dois dispositivos sem descarte silencioso, versão do modelo fixada na abertura, histórico de correções, permissões e início da semana na segunda-feira.

## O que está implementado

- Login, sessão segura e permissões por papel para administração, frota, supervisão, preenchimento e auditoria.
- Cadastros de empresas, locais, pessoas e ativos, com revisões de ativo.
- Associação de modelo/configuração ao ativo.
- Editor de modelos, campos de identificação, seções e itens; rascunho, nova versão, publicação, arquivamento e exclusão restrita de rascunho sem uso.
- Checklist semanal vinculado a uma versão e configuração imutáveis; inspeções e respostas separadas por data e ocorrência.
- Visão semanal em matriz, detalhes por data, identificação congelada, observações e histórico de correções.
- Calendário operacional por configuração; célula vazia não vira pendência fora dos slots exigidos e a interface avisa que um celular offline pode ainda não ter enviado dados.
- API transacional com validação Zod, autorização no servidor, erros Problem Details, `Idempotency-Key`, `If-Match`, recibos individuais de sincronização e log incremental com tombstones.
- Detecção de dois dispositivos no mesmo ativo/modelo/semana/data. A segunda criação é preservada como candidata, abre um conflito e exige resolução explícita: manter primária, manter separada quando permitido ou mesclar escolhas por item.
- Auditoria de criação, publicação, arquivamento, correção e resolução de conflitos.
- Migrações Drizzle e seed idempotente com os 14 modelos reais.

## Estrutura

```text
src/app/                       páginas e Route Handlers
src/features/*/domain          regras e validações
src/features/*/application     serviços de negócio
src/features/*/infrastructure  repositórios PostgreSQL
src/features/*/presentation    componentes da web
src/infrastructure/            banco, HTTP e utilidades compartilhadas
drizzle/                       migrações e metadados versionáveis
scripts/                       migração e seed
```

O contrato da API está em [openapi/openapi.yaml](openapi/openapi.yaml). As decisões de arquitetura e sincronização estão em [docs/architecture.md](docs/architecture.md), e a rastreabilidade da planilha em [docs/spreadsheet-analysis.md](docs/spreadsheet-analysis.md).

## Dependências externas e decisões pendentes

- Neon/PostgreSQL e um provedor OIDC precisam ser configurados fora do repositório; nenhuma credencial é enviada ao navegador.
- O armazenamento de binários em S3 compatível está preparado nas variáveis de ambiente, mas fotos e assinatura desenhada não foram ativadas. A especificação ainda não confirmou escopo diário/semanal, método de assinatura nem exigência de foto/observação para `NC`.
- Também permanecem configuráveis, sem suposição operacional: dias obrigatórios, mais de uma inspeção na data, campos obrigatórios e ações para `NC`.
- Não há bloqueio do veículo, aprovação automática ou reprovação implícita.
- O aplicativo Flutter/Drift está no primeiro recorte offline de VL; assinaturas, arquivos e a homologação OIDC/Bearer dependem das definições listadas abaixo.

## Aplicativo móvel Flutter

O cliente de preenchimento offline está em [`mobile/`](mobile/README.md). Ele usa Flutter, Dart, SQLite cifrado com Drift, OIDC/PKCE, outbox transacional e sincronização push/pull. A criação e administração de modelos continuam exclusivas da plataforma web.

Antes da homologação ponta a ponta, consulte as [lacunas contratuais do aplicativo móvel](docs/mobile-contract-gaps.md), especialmente identidade Bearer/JWKS, associação ativo-modelo, conteúdo do pull e semântica de mutações no `sync/push`.
