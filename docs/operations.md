# Operação e manutenção

## Configuração do ambiente

Copie `.env.example` para `.env.local` e configure o banco e a autenticação. Não versione `.env.local`, chaves de assinatura nem backups com dados.

| Variável                 | Uso                                                                                   |
| ------------------------ | ------------------------------------------------------------------------------------- |
| `DATABASE_URL`           | Conexão utilizada pela aplicação                                                      |
| `DATABASE_DIRECT_URL`    | Conexão preferencial para migrações, seed e manutenção; usa `DATABASE_URL` se ausente |
| `NEXTAUTH_URL`           | URL do painel no ambiente                                                             |
| `NEXTAUTH_SECRET`        | Assinatura da sessão web                                                              |
| `MOBILE_AUTH_SECRET`     | Assinatura dos tokens móveis; usa `NEXTAUTH_SECRET` se ausente                        |
| `AUTH_ALLOW_CREDENTIALS` | `true` habilita matrícula e senha                                                     |
| `DEFAULT_TIMEZONE`       | Fuso padrão; inicialmente `America/Fortaleza`                                         |
| `SEED_*`                 | Dados das contas e senhas iniciais de demonstração                                    |
| `OIDC_*`                 | Integração corporativa opcional                                                       |

Na produção, use HTTPS e segredos próprios do ambiente, com pelo menos 32 caracteres para a assinatura móvel. O endereço do banco nunca deve ser enviado ao navegador ou aplicativo.

## Migrações e seed

Na raiz do repositório:

```powershell
npm.cmd run db:migrate
```

O comando aplica as migrações pendentes no banco configurado. Ele não gera APK, não atualiza um aplicativo instalado e não carrega o catálogo por si só.

Migrações recentes:

| Migração                     | Finalidade                                                 |
| ---------------------------- | ---------------------------------------------------------- |
| `0005_optional_site_company` | Permitir local sem empresa vinculada                       |
| `0006_user_audit_names`      | Preservar nomes de autores e proteger eventos de auditoria |
| `0007_employee_number_login` | Adicionar matrícula única e tornar e-mail opcional         |

Antes de atualizar um ambiente com dados importantes, confirme o destino e disponha de backup/restauração do banco. Não altere uma migração já aplicada; crie uma nova para mudanças posteriores.

O seed é uma operação separada:

```powershell
npm.cmd run db:seed
```

Ele importa o catálogo e prepara exemplos de empresa, local, ativo, usuários e configuração. Não o execute apenas para corrigir uma senha ou depois de uma limpeza quando a intenção é manter o banco vazio de exemplos. Contas existentes não têm suas credenciais sobrescritas pelo seed.

## Matrículas de contas existentes

Uma conta criada antes da migração pode continuar com `employee_number` vazio. A migração não inventa matrículas nem converte IDs em números de funcionário.

Use uma sessão administrativa já aberta para entrar em **Usuários**, editar a conta e informar a matrícula real. Cadastre a matrícula do administrador antes de sair. Caso não exista sessão administrativa utilizável, a recuperação exige intervenção autorizada no banco; não é feita pelo login nem por um fluxo de recuperação pública.

O painel usa `users:manage`. As senhas novas têm mínimo de 10 caracteres e limite de 72 bytes UTF-8. Desativação da própria conta e remoção do último administrador ativo são bloqueadas.

## Desativação e auditoria

As ações normais de remoção de cadastros no painel são desativações. Registros deixam de ser usados em novos preenchimentos, preservando os vínculos históricos.

A página **Auditoria** exibe autor, ação, data e entidade. Novos eventos e revisões guardam o nome do autor, além do ID. Alterar o nome do usuário não modifica esses snapshots. Eventos legados sem nome preservado exibem o cadastro atual como fallback sinalizado.

Eventos de auditoria não são apagados pela limpeza de testes. Ela acrescenta um evento de manutenção com quantidades e hashes, sem atribuir a operação a uma conta que não foi autenticada no script.

## Limpeza definitiva de dados de teste

O script `scripts/cleanup-test-data.ts` existe para manutenção excepcional. **Ele remove todos os dados operacionais da organização selecionada**, e não apenas registros com nomes aparentemente aleatórios. O filtro por nome é aplicado somente aos modelos de formulário.

O escopo inclui empresas, locais, pessoas, ativos, semanas, inspeções, respostas, anexos nas revisões, vínculos, conflitos, recibos e log de sincronização. Modelos cujo nome contém `teste`, sem distinguir maiúsculas, também são removidos com suas versões, seções e itens.

São preservados:

- organização e contas de acesso;
- eventos de auditoria existentes;
- modelos sem `teste` no nome, com suas versões, seções, itens e configurações;
- dados de outras organizações.

Nas configurações preservadas, vínculos com locais removidos ficam vazios. O script registra tombstones de exclusão no novo log de sincronização. Esses tombstones não garantem, sozinhos, o descarte completo dos dados nos aplicativos atuais.

### Prévia

Com a organização autorizada explicitamente identificada:

```powershell
$taskOrganizationId = "UUID-DA-ORGANIZACAO"
node node_modules/tsx/dist/cli.mjs scripts/cleanup-test-data.ts --organization $taskOrganizationId
```

A execução padrão não apaga nada. Ela mostra quantidades, modelos removidos/preservados e `planHash`. Confira o escopo e a organização; não deduza o destino apenas pelo nome do ambiente.

### Execução autorizada

Mantenha os aplicativos de teste fechados. Depois de revisar a prévia e obter autorização para a exclusão:

```powershell
$taskPlanHash = "HASH-EXATO-DA-PREVIA"
node node_modules/tsx/dist/cli.mjs scripts/cleanup-test-data.ts --organization $taskOrganizationId --execute --expect-plan $taskPlanHash
```

O script bloqueia alterações concorrentes nas tabelas envolvidas, recalcula o plano e cancela se o hash mudou. Antes de excluir, grava um backup JSON em `.local-backups/`, pasta ignorada pelo Git. A exclusão e as verificações de preservação ficam em uma transação; uma falha provoca rollback no banco.

O backup contém dados operacionais e pode incluir fotos e informações pessoais. Controle o acesso e a retenção desses arquivos. Não há comando automático de restauração: uma recuperação precisa respeitar dependências, organização, estado do banco e log de sincronização. Esse arquivo não substitui a política de backup do PostgreSQL.

### Celulares após a limpeza

Limpar o servidor não limpa o banco Drift, as fotos nem a outbox de um aparelho. Uma fila antiga ainda pode tentar reenviar cadastros de teste.

Depois de confirmar que todo o conteúdo local pode ser descartado, use no Android **Configurações → Aplicativos → Checklist → Armazenamento → Limpar dados**. Limpar somente cache ou sair da conta não basta. Abra o aplicativo e entre novamente para carregar os catálogos preservados.

Não limpe dados de aparelhos com trabalho real pendente. O script não executa essa etapa remotamente.

## Preparação para distribuição

Antes de distribuir o Android:

1. Defina o identificador definitivo do aplicativo e sua assinatura release. O arquivo `mobile/android/app/build.gradle.kts` ainda usa identificador de exemplo e assinatura de debug para release.
2. Defina a URL HTTPS real com `API_BASE_URL` na compilação.
3. Confira migrações, contas e matrículas no ambiente de destino.
4. Homologue preenchimento offline, fotos, reenvios e conflitos em aparelhos reais.
5. Configure limite de tentativas de login, monitoramento e backup com restauração verificada.

As pendências funcionais estão em [Sincronização e limitações](mobile-contract-gaps.md). O repositório não comprova, por si só, que a infraestrutura externa já tenha essas medidas configuradas.
