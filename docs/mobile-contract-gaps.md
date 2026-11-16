# Definições necessárias para homologar o aplicativo móvel

O aplicativo implementa as partes independentes do fluxo offline e segue os caminhos existentes no OpenAPI. Os itens abaixo precisam ser definidos ou alinhados no servidor antes da homologação ponta a ponta.

## 1. Identidade móvel e Bearer token

O sistema usa as contas internas da tabela `users`. O mobile autentica por `POST /api/v1/auth/login`, renova a sessão por `POST /api/v1/auth/refresh` e encerra por `POST /api/v1/auth/logout`. Access tokens assinados têm duração de 15 minutos; refresh tokens aleatórios duram 30 dias, são armazenados somente como hash no servidor e rotacionam a cada uso.

As rotas `/api/v1` aceitam tanto a sessão web do NextAuth quanto `Authorization: Bearer ...` do mobile. Para produção ainda é necessário adicionar limitação distribuída de tentativas de login no proxy/gateway e um fluxo administrativo de criação, troca e recuperação de senha.

## 2. Escopo autorizado no bootstrap

O `MobileBootstrap` traz versões, ativos e configurações, porém não inclui:

- resumo do modelo (`code`, `name`, `assetKind`) junto da versão;
- associação entre ativo e modelo/configuração aplicável;
- empresas, locais e pessoas autorizadas para preencher a identificação;
- nomes de empresa/local referenciados pelos IDs;
- checklists e inspeções existentes necessários a um novo aparelho.

O aplicativo agora lista todos os modelos publicados com configuração ativa. Empresa, local, motorista/operador e ativo são escolhidos em listas e podem ser cadastrados no próprio aplicativo usando as rotas de cadastro existentes. Essas consultas e inclusões exigem conexão; o bootstrap ainda deve incorporar esses catálogos para que os seletores também funcionem integralmente offline.

## 3. Semântica de `/sync/push`

O servidor diferencia a primeira criação (sem `baseRevision`) de atualizações posteriores. `UPSERT` atualiza o rascunho, `COMPLETE` conclui usando a revisão conhecida pelo aparelho e ambas as operações possuem recibo idempotente por dispositivo/operação. O retorno atualiza `serverRevision` no banco local.

Continua pendente definir a regra e o motivo obrigatório para `VOID`; até essa definição, a anulação é recusada explicitamente.

## 4. Conteúdo do pull incremental

O contrato permite `payload` genérico. A implementação atual grava no change log de inspeção apenas um resumo, sem identificação e respostas. Para materializar ou atualizar inspeções de outro dispositivo, o pull precisa retornar o snapshot completo ou uma referência estável para `GET /inspections/{inspectionId}`.

Também deve ser confirmado se um novo bootstrap inclui semanas/inspeções já existentes ou se o cliente deve consultar outra coleção após o manifesto.

## 5. Configuração operacional

`OperationConfig` exige `requiredWeekdays`, mas o bootstrap atual seleciona diretamente `operation_configs`; os dias ficam em `operation_required_days`. O serviço deve agregá-los conforme o schema OpenAPI.

Ao publicar um modelo, o servidor cria uma configuração operacional padrão quando ainda não existe. A migração `0003_published_template_configs` faz o mesmo para modelos que já estavam publicados, permitindo que todos apareçam no manifesto mobile. A relação ativo → configuração continua sendo criada quando o usuário escolhe ou cadastra o ativo no aplicativo.

## 6. Assinaturas, fotos e arquivos

Fotos opcionais de inspeção foram ativadas no mobile: câmera/galeria, até cinco imagens de 2,5 MB, persistência offline e envio junto à revisão da inspeção. A ausência de foto nunca bloqueia a conclusão.

Continuam pendentes assinatura diária ou semanal, papéis e método de assinatura, além de um armazenamento de objetos dedicado com upload retomável e checksum. O contrato atual mantém as fotos na revisão versionada da inspeção e é adequado ao limite pequeno adotado no aplicativo.

## 7. Saída e troca de usuário

A regra segura implementada é:

- sessão expirada não apaga banco nem outbox;
- saída explícita remove tokens e preserva dados cifrados;
- a mesma conta pode autenticar novamente e continuar;
- outra conta é bloqueada para evitar acesso cruzado.

É necessário decidir se a troca de usuário deve usar bancos separados por conta, limpeza após sincronização confirmada ou transferência administrativa. Dados pendentes nunca devem ser apagados silenciosamente.

## 8. Cursores

O OpenAPI declara cursor como string opaca. O backend atual converte cursor para número em bootstrap/pull. O cliente preserva como string e não interpreta seu conteúdo; o servidor deve tratar o cursor de forma consistente.
