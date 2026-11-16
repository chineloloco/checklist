# Checklists operacionais — aplicativo Flutter

Cliente móvel offline-first para preenchimento de inspeções. A administração de modelos e usuários permanece na plataforma web. O aplicativo usa Flutter, Dart, SQLite cifrado e Drift.

## O que está implementado

- Login próprio com e-mail e senha cadastrados no backend.
- Access token de curta duração e refresh token rotativo no armazenamento seguro do aparelho.
- Bootstrap autenticado por `GET /api/v1/mobile/bootstrap`.
- Cache local de versões publicadas, seções, itens, ativos, empresas, locais, motoristas/operadores e configurações operacionais.
- Todos os formulários publicados aparecem antes da escolha do veículo ou equipamento.
- Seletores de empresa, local e motorista/operador listam os cadastros existentes e permitem criar novos registros no próprio aplicativo.
- Veículos e equipamentos podem ser cadastrados e vinculados ao formulário durante a abertura da semana.
- Banco Drift cifrado com SQLite3MultipleCiphers; a chave fica no `flutter_secure_storage`.
- Inspeções independentes por data e ocorrência, com respostas `C`, `NC`, `NA` ou sem resposta.
- Salvamento automático e outbox gravados na mesma transação.
- Push em lotes de até 100 operações e pull incremental por cursor.
- Sincronização na abertura/retomada, por ação manual e após mudança de conectividade.
- Estados visíveis de rascunho, concluída, pendente, enviando, sincronizada, falha e conflito.
- Saída da conta sem apagar rascunhos ou operações pendentes.
- Identificação utilizável offline com os cadastros recebidos no último bootstrap; novos cadastros continuam exigindo conexão.

## Pré-requisitos

- Flutter 3.44 ou superior
- Dart 3.12 ou superior
- Android 6.0+ ou iOS 15+
- Backend, PostgreSQL e usuários de teste configurados conforme o README da raiz

Para gerar os projetos nativos e o código Drift:

```powershell
cd C:\vs\Forms\mobile
flutter create --empty --platforms=android,ios --project-name checklist_mobile .
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

O `build_runner` gera `lib/features/checklists/data/local/app_database.g.dart`.

## Executar localmente

Primeiro, na raiz do projeto, aplique as migrações, carregue os usuários e inicie o backend:

```powershell
cd C:\vs\Forms
npm.cmd run db:migrate
npm.cmd run db:seed
npm.cmd run dev
```

Em outro terminal, inicie o aplicativo no emulador Android:

```powershell
cd C:\vs\Forms\mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

`10.0.2.2` é o endereço usado somente pelo emulador Android. Para testar em um aparelho físico conectado por USB, crie um túnel e use `127.0.0.1`:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" reverse tcp:3000 tcp:3000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

O túnel precisa ser recriado depois de desconectar/reconectar o aparelho ou reiniciar o ADB. Como alternativa, use o IP do computador na mesma rede Wi-Fi, por exemplo `http://192.168.0.10:3000`. Em produção, use somente HTTPS, por exemplo:

```powershell
flutter run --dart-define=API_BASE_URL=https://checklist.suaempresa.com
```

`API_BASE_URL` é o host da plataforma, sem `/api/v1`. O aplicativo nunca recebe URL ou credencial do PostgreSQL/Neon.

Os usuários iniciais são definidos na raiz em `.env.local`:

```text
SEED_ADMIN_EMAIL=admin@checklist.local
SEED_ADMIN_PASSWORD=troque-esta-senha
SEED_INSPECTOR_EMAIL=responsavel@checklist.local
SEED_INSPECTOR_PASSWORD=troque-esta-senha
```

Depois de alterar uma senha de seed em um banco que já possui o usuário, recrie ou atualize explicitamente esse usuário; o seed é idempotente e não sobrescreve contas existentes.

## Verificações

```powershell
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Estrutura

```text
lib/
  app/                       composição e ciclo de vida
  core/                      configuração, erros, tema, rede e datas
  features/auth/
    domain/                  sessão e contrato do repositório
    data/                    login, renovação e armazenamento seguro
    presentation/            formulário de entrada
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

Consulte [`../docs/mobile-contract-gaps.md`](../docs/mobile-contract-gaps.md) antes de homologar a sincronização: ainda há decisões de contrato sobre bootstrap, mutações, pull incremental e anexos.
