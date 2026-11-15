# Definições necessárias para homologar o aplicativo móvel

O aplicativo implementa as partes independentes do fluxo offline e segue os caminhos existentes no OpenAPI. Os itens abaixo precisam ser definidos ou alinhados no servidor antes da homologação ponta a ponta.

## 1. Identidade móvel e Bearer token

O OpenAPI define Authorization Code com PKCE, mas `authorizationUrl` e `tokenUrl` ainda usam `identity.example.com`. É necessário confirmar `issuer`, `client_id`, redirect URIs, audiência, scopes, rotação/revogação do refresh token e logout.

O backend atual obtém identidade apenas por `getServerSession(NextAuth)`. As rotas `/api/v1` ainda precisam aceitar e validar `Authorization: Bearer ...` por emissor, audiência, expiração e JWKS, conforme a arquitetura.

## 2. Escopo autorizado no bootstrap

O `MobileBootstrap` traz versões, ativos e configurações, porém não inclui:

- resumo do modelo (`code`, `name`, `assetKind`) junto da versão;
- associação entre ativo e modelo/configuração aplicável;
- empresas, locais e pessoas autorizadas para preencher a identificação;
- nomes de empresa/local referenciados pelos IDs;
- checklists e inspeções existentes necessários a um novo aparelho.

No primeiro recorte, o aplicativo consegue usar VL quando há uma única versão/configuração publicada e permite digitar empresa, local e responsável. Isso não substitui a definição contratual dos cadastros autorizados.

## 3. Semântica de `/sync/push`

O OpenAPI aceita `mutation: UPSERT | COMPLETE | VOID`. A implementação atual do `SyncService.push` chama `createInspection` para qualquer operação de inspeção e não diferencia atualização, conclusão ou anulação.

É necessário implementar no servidor:

- criação pelo `clientInspectionId` na primeira operação;
- atualização de rascunho com `baseRevision`;
- conclusão independente por `COMPLETE`;
- anulação somente com regra e motivo definidos;
- recibo idempotente para cada mutação;
- retorno coerente de `serverRevision`.

Sem esse alinhamento, o primeiro envio pode criar a inspeção, mas alterações posteriores não têm comportamento garantido pelo backend atual.

## 4. Conteúdo do pull incremental

O contrato permite `payload` genérico. A implementação atual grava no change log de inspeção apenas um resumo, sem identificação e respostas. Para materializar ou atualizar inspeções de outro dispositivo, o pull precisa retornar o snapshot completo ou uma referência estável para `GET /inspections/{inspectionId}`.

Também deve ser confirmado se um novo bootstrap inclui semanas/inspeções já existentes ou se o cliente deve consultar outra coleção após o manifesto.

## 5. Configuração operacional

`OperationConfig` exige `requiredWeekdays`, mas o bootstrap atual seleciona diretamente `operation_configs`; os dias ficam em `operation_required_days`. O serviço deve agregá-los conforme o schema OpenAPI.

Também falta explicitar no bootstrap a relação ativo → configuração para evitar oferecer modelos incompatíveis.

## 6. Assinaturas, fotos e arquivos

Continuam pendentes:

- assinatura diária ou semanal;
- papéis que assinam;
- método/evidência da assinatura;
- obrigatoriedade de observação ou foto para `NC`;
- endpoints de criação, upload, retomada, checksum e confirmação de anexos.

A tabela local de anexos e seus estados foi criada, mas nenhuma coleta ou chamada HTTP foi ativada.

## 7. Saída e troca de usuário

A regra segura implementada é:

- sessão expirada não apaga banco nem outbox;
- saída explícita remove tokens e preserva dados cifrados;
- a mesma conta pode autenticar novamente e continuar;
- outra conta é bloqueada para evitar acesso cruzado.

É necessário decidir se a troca de usuário deve usar bancos separados por conta, limpeza após sincronização confirmada ou transferência administrativa. Dados pendentes nunca devem ser apagados silenciosamente.

## 8. Cursores

O OpenAPI declara cursor como string opaca. O backend atual converte cursor para número em bootstrap/pull. O cliente preserva como string e não interpreta seu conteúdo; o servidor deve tratar o cursor de forma consistente.
