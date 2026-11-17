# Aplicativo Flutter

Cliente de preenchimento offline para a plataforma de checklists. A administração de usuários e modelos ocorre no painel web. O aplicativo usa Drift, SQLite3MultipleCiphers e armazenamento seguro para chave do banco e tokens.

## Preparação

Use Flutter com Dart compatível com `environment.sdk` de [pubspec.yaml](pubspec.yaml), atualmente `>=3.12.0 <4.0.0`, e as ferramentas nativas da plataforma desejada.

Os projetos Android e iOS já existem no repositório. Não é necessário executar `flutter create` na instalação normal.

A partir da raiz:

```powershell
Set-Location mobile
flutter pub get
```

O arquivo `app_database.g.dart` é gerado. Ao alterar as tabelas Drift, regenere-o:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

## Conectar ao backend

Prepare o backend seguindo [o README da raiz](../README.md). Migrações são aplicadas na raiz; o seed é opcional e cria dados de demonstração.

Com o backend local na porta 3000, execute em `mobile/`:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

`10.0.2.2` é destinado ao emulador Android. Para um aparelho Android conectado por USB:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" reverse tcp:3000 tcp:3000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Recrie o túnel após reconectar o aparelho ou reiniciar o ADB. Para conexão pela rede local, use o endereço do computador alcançável pelo celular e permita a porta no firewall.

Na distribuição, configure a URL HTTPS real:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://checklist.suaempresa.com
```

O projeto ainda precisa de identificador e assinatura release definitivos antes da distribuição. A configuração atual do Android utiliza assinatura de debug também no tipo release. Consulte [a operação do projeto](../docs/operations.md).

`API_BASE_URL` é o host da plataforma, sem `/api/v1`. O celular não recebe credenciais do PostgreSQL.

## Login

Entre com **matrícula e senha** cadastradas em **Usuários** no painel. Matrícula é texto: `001234` mantém seus zeros. O primeiro acesso e o carregamento inicial precisam de internet.

A sessão fica salva no armazenamento seguro. Access tokens duram 15 minutos; refresh tokens duram 30 dias e rotacionam. O aplicativo permite continuar o preenchimento local sem sinal após o acesso inicial; enviar dados exige uma sessão aceita pelo servidor.

A conta autenticada identifica o autor do preenchimento. O motorista/operador escolhido na identificação pode ser outra pessoa.

Ao sair, os tokens são removidos, mas os dados locais e a fila permanecem. A mesma conta pode voltar. Outra conta é bloqueada enquanto o aparelho contém dados da conta anterior; não há separação automática de bancos por usuário.

## Preenchimento e cadastros offline

1. Selecione um modelo publicado com configuração ativa.
2. Selecione ou cadastre o ativo e os dados da identificação.
3. Abra a semana/data e preencha as respostas.
4. Continue depois ou conclua a inspeção.
5. Sincronize ao recuperar conexão e confira a confirmação.

Empresa, local, motorista/operador e ativo podem ser cadastrados offline. Os seletores consultam o banco local, possuem busca e usam o catálogo do último bootstrap. Novos cadastros ficam na fila para envio.

Respostas e fila são gravadas na mesma transação. Tocar na resposta selecionada a desmarca. Selecionar uma resposta provoca uma rolagem suave. A conclusão valida os itens obrigatórios e as observações exigidas para `NC`.

Fotos são opcionais: câmera ou galeria, até cinco imagens por inspeção, com limite local de 2,5 MB por imagem. São persistidas no aparelho e enviadas em base64 junto à revisão.

## Sincronização

O coordenador envia dependências antes dos preenchimentos: empresas, locais, pessoas, ativos, semanas, inspeções e eventos de auditoria locais. Os lotes têm no máximo 100 operações.

Depois que uma operação foi tentada, seu conteúdo é preservado para reenvio. Edições posteriores seguem em outra operação e aguardam a revisão confirmada pelo servidor. A fila não é apagada por falha de rede ou sessão expirada.

Uma inspeção ainda não enviada pode ser desativada localmente. Sua criação pendente é removida da fila e um evento `AUDIT_EVENT/VOID` registra a ação na próxima sincronização. Isso não permite anular uma inspeção já enviada.

O aplicativo ainda não materializa inspeções desconhecidas recebidas de outro celular. O pull também não substitui todo o conteúdo das inspeções locais por snapshots remotos completos. Consulte [as limitações](../docs/mobile-contract-gaps.md).

## Após uma limpeza excepcional de testes

O banco local pode conter dados e operações que foram removidos do servidor. Sair da conta ou apenas limpar o cache não remove essa fila.

Depois de confirmar que os dados locais podem ser descartados, mantenha o aplicativo fechado e use no Android **Configurações → Aplicativos → Checklist → Armazenamento → Limpar dados**. Em seguida, abra o aplicativo e faça login novamente.

Esse procedimento apaga rascunhos e fotos locais. Não o use como solução para falhas comuns de sincronização nem quando houver dados de trabalho ainda não enviados.

## Verificação

Em `mobile/`:

```powershell
flutter analyze
flutter test
```

Para formatar somente fontes e testes escritos no projeto, sem o arquivo gerado:

```powershell
$taskDartFiles = Get-ChildItem lib,test -Recurse -Filter *.dart | Where-Object { $_.Name -notlike '*.g.dart' } | Select-Object -ExpandProperty FullName
dart format $taskDartFiles
```

## Estrutura

```text
lib/app/                    composição, sessão e ciclo de vida
lib/core/                   configuração, HTTP, erros, tema e widgets
lib/features/auth/          login e armazenamento da sessão
lib/features/checklists/    modelos, banco local, repositórios e telas
lib/features/sync/          fila, coordenador, API e estados
test/                       testes de domínio, persistência e interface
```
