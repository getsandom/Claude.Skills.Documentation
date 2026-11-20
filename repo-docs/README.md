# repo-docs

Plugin do Claude Code para documentação embutida e versionada no próprio
repositório, na pasta `docs/`, organizada em **tópicos**.

## Modelo de tópico

Cada tópico é uma pasta:

```
topico/
├─ README.md          apresentação: o porquê do tópico e os documentos mais relevantes
├─ <documentos>       conteúdo
├─ <subtopico>/       subtópico, com a mesma estrutura
└─ .meta/
   ├─ index.md        uma linha por documento e subtópico, para consulta rápida
   ├─ regras.md       campos fixos (identificador, modelo, encerramento...) e regras em prosa
   └─ modelo.md       (opcional) estrutura dos documentos
```

A raiz `docs/` também é um tópico; `docs/.meta/regras.md` traz as regras que valem
para todos (formato dos índices, identificadores `PRE_NNN`, histórico, convenções).

## Comandos

| Comando | O que faz |
|---|---|
| `/repo-docs:init [projeto]` | Cria `docs/` a partir dos presets, entrevistando o usuário sobre tópicos, subtópicos, glossário, regra de documentação no código, padrão de commits e o trecho do `CLAUDE.md`. |
| `/repo-docs:add-topic [nome]` | Adiciona um tópico ou subtópico, a partir de um preset ou definido do zero. |
| `/repo-docs:sync [operação]` | Cria, altera, encerra, move ou renomeia documentos aplicando as regras: próximo identificador, índice, README e histórico. Revisa os TODO/FIXME dos arquivos alterados contra as pendências; com `--todos-completo`, os do repositório inteiro. Também é acionado automaticamente quando a tarefa envolve documentos em `docs/`. |
| `/repo-docs:audit [pasta]` | Verifica a documentação sem alterá-la: script mecânico e verificação de conteúdo. |
| `/repo-docs:migrate [caminho]` | Localiza a documentação existente (`docs/` em outro formato, Markdown espalhado, seções de `README.md`/`CLAUDE.md`, TODO/FIXME) e a migra por inventário, plano e execução, com renumeração dos identificadores; o plano e depois o registro ficam em `docs/.meta/migracao.md`. |

## Presets

O catálogo está em [presets/catalogo.md](presets/catalogo.md).

| Preset | Identificador | Subtópicos |
|---|---|---|
| `requisitos` | — | `usuario/` (`RQU`), `sistema/` (`RQS`) |
| `decisoes` | `DEC` | — |
| `arquitetura` | — | `dominio/` (opcional) |
| `melhorias` | `MEL` | — |
| `pendencias` | `PEN` | `resolvidas/` |
| `historico` | — | — |
| `suporte` | — | — |
| `scripts` | — | — |
| `tarefas` | `TAR` (passos `TAR_NNN.XX`) | `concluidas/` |

Opcionais da raiz: `glossario.md` e a regra de documentação no código autocontida.
As regras gerais registram o padrão das mensagens de commit, escolhido no `init`.

`tarefas` usa documentos em pasta: cada tarefa é uma pasta `TAR_NNN-titulo/`, um
subtópico com `README.md`, `.meta/` e um arquivo por passo (`TAR_NNN.XX-titulo.md`),
planejado para execução em sequência por agentes de IA.

## Verificação mecânica

`skills/audit/scripts/audit.ps1` e `skills/audit/scripts/audit.sh` produzem a mesma
saída e podem ser usados fora do Claude Code, inclusive em CI:

```bash
bash repo-docs/skills/audit/scripts/audit.sh docs
bash repo-docs/skills/audit/scripts/audit.sh --next-id DEC docs
bash repo-docs/skills/audit/scripts/audit.sh --next-id TAR_001 docs
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File repo-docs/skills/audit/scripts/audit.ps1 docs
powershell -NoProfile -ExecutionPolicy Bypass -File repo-docs/skills/audit/scripts/audit.ps1 -NextId DEC docs
powershell -NoProfile -ExecutionPolicy Bypass -File repo-docs/skills/audit/scripts/audit.ps1 -NextId TAR_001 docs
```

Com um prefixo (`DEC`), `--next-id` imprime o próximo identificador; com o
identificador de um documento em pasta (`TAR_001`), o próximo sub-identificador
(`TAR_001.03`).

Código de saída: 0 sem erros, 1 com erros, 2 em uso inválido.

`skills/migrate/scripts/inventory.ps1` e `inventory.sh` listam, com a mesma saída,
documentos de texto fora da documentação estruturada (`--markdown`), ocorrências de
TODO/FIXME (`--todos [arquivos...]`) e referências literais fora de `docs/`
(`--refs PADRÃO`).

## Limitações

- O `audit` verifica o conteúdo por leitura do modelo, por amostragem em
  documentações grandes.
