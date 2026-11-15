# Análise da planilha de origem

## Resultado da extração

A planilha contém as 14 abas informadas e 538 itens de inspeção. O catálogo completo está em `specs/template-catalog.json`. Cada item conserva:

- aba e linha de origem;
- número impresso, apenas como referência;
- redação original, inclusive capitalização, pontuação e eventuais erros de digitação;
- seção explícita quando ela existe na planilha.

| Código | Cabeçalho identificado | Tipo | Itens | Campo específico |
|---|---|---:|---:|---|
| CB | Veículo para transporte de combustíveis | veículo | 40 | vencimento MOPP |
| CBA | Caminhão basculante | veículo | 38 | — |
| CC | Caminhão carroceria | veículo | 38 | — |
| CP | Caminhão pipa | veículo | 41 | — |
| CM | Caminhão Munk | veículo | 40 | seções CINTAS, GANCHOS e OUTROS |
| ONIBUS | Ônibus | veículo | 39 | curso de transporte de passageiros |
| MO | Micro-ônibus | veículo | 40 | curso de transporte de passageiros |
| VA | Van | veículo | 40 | curso de transporte de passageiros |
| VL | Veículos leves | veículo | 34 | primeiro recorte |
| C_PRANCHA | Caminhão prancha | veículo | 38 | — |
| MT | Motoniveladora | equipamento | 37 | fabricante |
| TP | Trator de pneu | equipamento | 37 | fabricante |
| TE | **não informado no cabeçalho** | equipamento | 38 | identificação pendente |
| PC | Pá carregadeira | equipamento | 38 | fabricante |

## Campos observados

Todos os modelos trazem empresa, local, ano de fabricação, cor predominante, código, indicação de próprio/terceiro, responsável, CNH e vencimento. Os modelos de veículos trazem placa, marca e modelo; os de equipamentos trazem fabricante. `CB` traz o vencimento do MOPP. `ONIBUS`, `MO` e `VA` trazem o vencimento do curso de transporte de passageiros.

As colunas impressas representam até sete datas e, para cada data, uma escolha exclusiva entre `C`, `NC` e `NA`. No sistema, essas colunas serão inspeções relacionadas, e não sete campos fixos.

## Ambiguidades preservadas

- A aba `TE - Semanal` não identifica o equipamento. O catálogo usa `name: null` e `PENDING_CONFIRMATION`.
- A numeração impressa possui lacunas, reinícios e omissões em várias abas. Ela não será chave de negócio.
- Há grafias possivelmente incorretas, como “Parredes”, “Bateira”, “Aplicavél” e “dasmangueiras”. A versão importada preserva o original. Uma correção futura exige nova versão publicada.
- Alguns itens agrupam várias verificações em uma frase. Não serão desmembrados sem validação do responsável pelo processo.
- Os títulos “VEÍCULO PRÓPRIO/TERCEIROS” também aparecem nos modelos de máquinas. O dado será modelado como `ownership_type`, sem inferir que a máquina é um veículo.
- A planilha não define quais dias são obrigatórios, se há várias inspeções por data, se assinaturas são diárias ou semanais, nem regras adicionais para `NC`.

## Modelo VL importado

O primeiro modelo contém 34 itens, de “Carteira de habilitação” a “Vazamentos”. A publicação inicial cria uma versão imutável com os textos do catálogo, uma seção `Itens gerais` e respostas `C/NC/NA`. A configuração de obrigatoriedade, fotos e observação para `NC` permanece neutra até confirmação.
