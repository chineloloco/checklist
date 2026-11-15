# Checklists operacionais — aplicativo Flutter

Cliente móvel offline-first para preenchimento de inspeções. A administração de modelos permanece na plataforma web. O aplicativo usa Flutter, Dart, SQLite cifrado e Drift, com código organizado por apresentação, domínio, aplicação e dados.

## O que está implementado

- OIDC/OAuth 2.1 Authorization Code com PKCE e refresh token rotativo no armazenamento seguro do sistema.
- Bootstrap autenticado por `GET /api/v1/mobile/bootstrap`.
- Cache local de versões publicadas, seções, itens, ativos e configurações operacionais.
- Banco Drift cifrado com SQLite3MultipleCiphers; a chave fica no `flutter_secure_storage`.
- Semana local com versão do modelo fixada no momento da abertura.
- Inspeções independentes por data e ocorrência.
- 34 itens reais do modelo VL, gerados pelo modelo publicado baixado. O catálogo real também está em `assets/template-catalog.json` como fixture de teste.
- Respostas `C`, `NC`, `NA` ou sem resposta, sem valor padrão.
- Identificação congelada por inspeção, observações por item e observação geral.
- Salvamento automático: alteração de domínio e operação da outbox são gravadas na mesma transação.
- Conclusão de uma data sem depender dos demais dias da semana.
- Push em lotes de até 100 operações e pull incremental por cursor.
- Idempotência por `operationId`, fila persistente, tentativas, sessão expirada, rejeição e conflito.
- Sincronização na abertura/retomada, por ação manual e após mudança de conectividade. Conectividade não é tratada como prova de acesso à internet.
- Estados visíveis por texto, ícone e cor: rascunho, concluída, pendente, enviando, sincronizada, falha e conflito.
- Saída da conta sem apagar rascunhos ou outbox.
- Estrutura de anexos local separada. Coleta e envio permanecem desativados enquanto contrato e regras estiverem pendentes.

## Pré-requisitos

- Flutter 3.44 ou superior
- Dart 3.12 ou superior
- Android 6.0+ ou iOS 15+
- Um provedor OIDC configurado para aplicativo nativo com PKCE
- API com validação de Bearer token por JWKS

O Flutter não estava instalado no ambiente em que este código foi preparado. Para gerar os projetos nativos:

```powershell
cd mobile
flutter create --empty --platforms=android,ios --project-name checklist_mobile .
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

O `build_runner` gera `lib/features/checklists/data/local/app_database.g.dart`.

## Configuração do redirect OIDC

Exemplo:

```text
com.example.checklist:/oauthredirect
```

No Android, configure o mesmo scheme em `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        manifestPlaceholders["appAuthRedirectScheme"] = "com.example.checklist"
    }
}
```

No iOS, adicione em `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.example.checklist</string>
    </array>
  </dict>
</array>
```

Cadastre exatamente a mesma redirect URI no provedor OIDC.

## Executar

```powershell
flutter run `
  --dart-define=API_BASE_URL=https://seu-host.example.com `
  --dart-define=OIDC_ISSUER=https://identidade.example.com `
  --dart-define=OIDC_CLIENT_ID=checklist-mobile `
  --dart-define=OIDC_REDIRECT_URL=com.example.checklist:/oauthredirect
```

`API_BASE_URL` é o host da plataforma, sem `/api/v1`. O aplicativo acrescenta esse prefixo conforme o OpenAPI. Nenhuma URL ou credencial do Neon deve ser adicionada ao aplicativo.

## Verificações

Depois de gerar o código Drift:

```powershell
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Os testes entregues verificam:

1. duas datas offline na mesma semana com respostas independentes;
2. 34 itens reais de VL, de “Carteira de habilitação” a “Vazamentos”;
3. reinício do banco e recuperação de respostas/outbox;
4. versão do modelo preservada durante a semana;
5. uma data concluída enquanto outra continua em rascunho;
6. repetição da sincronização sem novo envio depois da confirmação;
7. falha de rede preservando payload e `operationId` para nova tentativa;
8. sessão expirada preservando a outbox e retomando com os mesmos IDs;
9. conflito de outro dispositivo preservando a inspeção e bloqueando somente sua operação.

## Estrutura

```text
lib/
  app/                       composição e ciclo de vida
  core/                      configuração, erros, tema, rede e datas
  features/auth/
    domain/                  sessão e contrato do repositório
    data/                    OIDC PKCE e armazenamento seguro
    presentation/            entrada
  features/checklists/
    domain/                  modelos e contrato do repositório
    application/             casos de uso
    data/local/              tabelas Drift e banco cifrado
    data/remote/             bootstrap e identidade da API
    presentation/            semana, data e editor móvel
  features/sync/
    domain/                  operações e estado da sincronização
    application/             push/pull e política de tentativas
    data/                    API e identidade do dispositivo
    presentation/            estado e sincronização manual
```

O código não inventa operações ausentes. Consulte [`../docs/mobile-contract-gaps.md`](../docs/mobile-contract-gaps.md) antes de homologar a sincronização contra o backend atual.
