# Sincronização: estado atual e pendências

Este documento distingue o comportamento implementado das limitações atuais. As fontes principais são `SyncService` no servidor, `SyncCoordinator` no Flutter e os schemas de domínio.

## Identidade e acesso

Implementado:

- Login interno por matrícula e senha; sessão web NextAuth e Bearer no aplicativo.
- Access token de 15 minutos, refresh token de 30 dias, rotação e revogação de refresh tokens.
- Verificação da conta ativa e dos perfis atuais no banco durante a autorização.
- Administração de contas, perfis e redefinição de senha em `/usuarios`, restrita a `ORG_ADMIN`.

Pendente: limitação de tentativas de login, recuperação de senha pelo próprio usuário e invalidação completa das sessões web e dos access tokens já emitidos após redefinição de senha. A revogação de refresh tokens, isoladamente, não representa encerramento imediato de todos os acessos.

## Bootstrap e cadastros

O bootstrap completo inclui:

- versões publicadas com os dados do modelo;
- ativos, empresas, locais e pessoas ativos;
- configurações operacionais e seus `requiredWeekdays`;
- associações ativo/modelo/configuração;
- horário do servidor, fuso, início da semana e cursor.

Os seletores funcionam localmente. Empresa, local, pessoa e ativo podem ser cadastrados offline e enviados antes das inspeções.

O bootstrap **não inclui o histórico completo de semanas e inspeções existentes**. Uma instalação nova ainda não recupera automaticamente todos os formulários preenchidos por outro aparelho.

A consulta com `sinceCursor` usa o fluxo incremental; consumidores não devem assumir que ela sempre retorna o mesmo objeto de um bootstrap completo.

## Push e reenvios

| Entidade                     | Operação implementada                                                                              |
| ---------------------------- | -------------------------------------------------------------------------------------------------- |
| COMPANY, SITE, PERSON, ASSET | Criação offline por `UPSERT`, sem revisão base; edição e desativação usam rotas próprias no painel |
| WEEKLY_CHECKLIST             | Abertura idempotente da semana; preserva versão/configuração solicitadas                           |
| INSPECTION sem revisão base  | Criação com UUID do cliente                                                                        |
| INSPECTION com revisão base  | Atualização do rascunho ou conclusão                                                               |
| AUDIT_EVENT                  | `VOID` registra a desativação de um rascunho local, sem anular inspeção no servidor                |

O cliente envia até 100 operações por lote e respeita as dependências. Na confirmação, usa o ID e a revisão retornados pelo servidor.

Reenvio de inspeção preserva operação e conteúdo. Edição feita durante um envio ou após uma resposta perdida fica em uma operação posterior. A confirmação da primeira fornece a revisão base para a próxima.

Dois UUIDs de inspeção para o mesmo slot podem gerar um conflito. As respostas candidatas são preservadas para resolução no painel.

Pendente: fluxo de anulação de inspeções já enviadas, com regra de permissão e motivo. `AUDIT_EVENT/VOID` não implementa essa anulação.

## Pull e troca de aparelho

O log de inspeções contém um resumo, não o snapshot completo das respostas, identificação e fotos. O cliente atual só aplica certas atualizações a inspeções e semanas já existentes no banco local.

Falta materializar registros desconhecidos e atualizar seu conteúdo a partir de snapshots completos ou consultas de detalhes. Essa é a principal lacuna para consultar no celular um preenchimento realizado em outro aparelho.

A paginação atual carrega o log da organização antes de filtrar e limitar os registros em memória. Deve passar a filtrar por sequência e limitar no PostgreSQL para crescer com o volume de uso.

O cliente mantém o cursor como texto; o servidor interpreta uma sequência numérica. Não há atualmente um formato de cursor opaco independente dessa sequência.

## Calendário e versões

O servidor agrega os dias de `operation_required_days` no bootstrap. Ao publicar um modelo sem configuração ativa, cria uma configuração padrão.

A semana fixa `templateVersionId` e `operationConfigId`. A publicação posterior de um modelo não substitui os itens das semanas anteriores.

Os dias exigidos, a multiplicidade por data e as exigências para `NC` precisam ser definidos para a operação real. Uma célula vazia não significa automaticamente ausência de preenchimento obrigatório.

## Fotos e assinaturas

Implementado: até cinco fotos opcionais, persistidas offline e enviadas em base64 na revisão. A API possui uma rota autenticada para leitura do anexo.

Pendente: armazenamento de objetos dedicado, upload retomável e política de retenção. Assinaturas diárias/semanais e o método de coleta ainda não foram ativados.

## Conta local e exclusões

Sair ou perder a sessão preserva o banco e a outbox. Outra conta é bloqueada para evitar acesso cruzado. Falta separar os dados por conta ou definir uma troca administrativa segura.

O tratamento de tombstones no aplicativo ainda é parcial; ele não constitui uma limpeza completa dos cadastros e preenchimentos locais. Uma limpeza excepcional no servidor exige também descartar os dados de teste nos aparelhos autorizados. O procedimento está em [Operação e manutenção](operations.md).

## Homologação necessária

- Criar e concluir formulários sem rede, reiniciar o aparelho e recuperar a fila.
- Interromper o envio antes e depois da gravação no servidor e repetir sem duplicar.
- Editar durante o envio e confirmar a aplicação das revisões em ordem.
- Criar cadastros offline e conferir sua chegada antes das inspeções.
- Confrontar dois aparelhos no mesmo slot e resolver o conflito no painel.
- Conferir matrícula, bloqueio de conta, sessão expirada e preservação dos dados locais.
- Testar buscas, teclado, barra de navegação, fotos e telas menores em aparelhos reais.

Os testes automatizados cobrem partes desses fluxos; não equivalem à homologação completa em dispositivos.
