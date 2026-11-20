# Diretrizes da coleção

Padrões para criar e manter plugins e skills neste repositório, seguidos das
decisões que os fundamentam.

- **Atualizado em:** 13/11/2026

## Estrutura do repositório

```
Claude.Skills.Documentation/
├─ .claude-plugin/marketplace.json     marketplace da coleção
├─ README.md                           apresentação e instalação
├─ GUIDELINES.md                       este documento
└─ <plugin>/                           um plugin por origem de documentação
   ├─ .claude-plugin/plugin.json
   ├─ README.md                        comandos, conceitos e limitações do plugin
   ├─ <recursos compartilhados>/       ex.: presets/, usados por mais de uma skill
   └─ skills/<comando>/SKILL.md        uma skill por comando
      └─ scripts/                      scripts da skill, quando houver
```

## Plugins

- Um plugin por origem de documentação, na raiz do repositório, nomeado
  `<origem>-docs` em kebab-case (`repo-docs`; futuras fontes em nuvem, como
  `notion-docs` ou `confluence-docs`).
- Todo plugin é listado em `.claude-plugin/marketplace.json` com `source` relativo
  (`./<plugin>`); o `name` da entrada é igual ao `name` do `plugin.json`.
- Recursos usados por mais de uma skill ficam na raiz do plugin e são referenciados
  por `${CLAUDE_PLUGIN_ROOT}`. Nada fora da pasta do plugin é referenciado: na
  instalação, só a pasta do plugin é copiada.
- `version` em `plugin.json` e na entrada do marketplace, em versionamento semântico,
  incrementada a cada mudança publicada.

## Skills

- Uma skill por comando, em `skills/<comando>/SKILL.md`, invocada como
  `/<plugin>:<comando>`. Nomes de comando curtos, em inglês e kebab-case, iguais
  entre plugins quando o papel for o mesmo (`init`, `add-topic`, `sync`, `audit`).
- Frontmatter mínimo: `name`, `description` e `argument-hint` quando houver
  argumento.
- Skills que criam estrutura ou só verificam (`init`, `add-topic`, `audit`) usam
  `disable-model-invocation: true`. Skills de manutenção (`sync`) podem ser
  acionadas pelo modelo, e a `description` diz quando.
- Instruções, descrições e conteúdo gerado em português, com tom formal.
- Toda decisão do usuário é perguntada um item por vez; nada é sobrescrito, movido
  ou removido sem aprovação, e nenhuma skill faz commit sem pedido.
- Toda skill que altera arquivos termina pela verificação mecânica (`audit`) do
  plugin, quando houver.

## Scripts

- Verificações mecânicas ficam em scripts, não em instruções ao modelo, para que o
  resultado seja reproduzível.
- Todo script existe em par, `.ps1` (Windows PowerShell 5.1 e PowerShell 7) e `.sh`
  (bash, sem extensões GNU), com os mesmos parâmetros, a mesma saída e os mesmos
  códigos de saída. Toda mudança em um é feita no outro e verificada comparando as
  saídas sobre as mesmas árvores de teste.
- Os `.ps1` são gravados em UTF-8 com BOM, para que o Windows PowerShell 5.1 leia
  corretamente os textos acentuados; os `.sh`, em UTF-8 sem BOM e com fim de linha LF.
- Scripts são só de leitura, salvo quando o nome e a documentação disserem o
  contrário.

## Decisões

### Nome `repo-docs`

O plugin cobre a documentação embutida e versionada no repositório. O nome
`local-docs` foi descartado por sugerir algo local da máquina, não versionado. O
sufixo `-docs` agrupa os plugins da coleção por origem.

### Marketplace com um plugin por origem, na raiz

A coleção é um marketplace para que a instalação e a atualização sejam feitas pelo
próprio Claude Code em qualquer máquina. Cada origem de documentação é um plugin
separado, para que os comandos fiquem `/repo-docs:init` e não dependam do nome da
coleção. A pasta intermediária `plugins/` foi dispensada, deixando cada plugin com
suas skills perto da raiz. As alternativas descartadas foram pastas soltas copiadas
para `~/.claude/skills` e um plugin único para toda a coleção.

### Documentação em tópicos com `.meta/`

A estrutura do Claude.Herald foi generalizada: requisitos, decisões e demais pastas
passam a ser **tópicos** de um mesmo formato. Cada tópico separa a apresentação
(`README.md`, exibido pelo GitHub ao abrir a pasta) dos metadados (`.meta/index.md`,
`.meta/regras.md`, `.meta/modelo.md`), para que as regras de cada tópico fiquem
explícitas e as skills não dependam de tópicos fixos. A raiz `docs/` também é um
tópico, com as regras transversais. Os tópicos do Herald são oferecidos como presets.

### Regras em campos fixos e prosa

O `.meta/regras.md` começa por campos em negrito (Identificador, Modelo, Nome do
arquivo, Descrição no índice, Ao encerrar, Subtópicos), legíveis no GitHub e lidos
pelo script de verificação, seguidos de regras em prosa. Front matter YAML foi
descartado por fugir do estilo dos documentos.

### Comandos `init`, `add-topic`, `sync` e `audit`

`init` cria a estrutura por entrevista; `add-topic` acrescenta tópicos depois;
`sync` aplica as regras a cada mudança de documento; `audit` só verifica. Um comando
por operação de manutenção foi descartado em favor de um `sync` único, acionável
pelo modelo.

### `CLAUDE.md` do projeto

O `init` propõe um trecho para o `CLAUDE.md` do projeto, gravado só com aprovação,
para que sessões futuras sigam a estrutura sem invocar o plugin.

### Migração por inventário, plano e registro

O comando `migrate` traz para a estrutura a documentação existente: `docs/` em
outro formato, Markdown espalhado, seções de `README.md` e `CLAUDE.md` e TODO/FIXME
no código. O fluxo em três fases (inventário, plano aprovado, execução) permite
revisar antes de mover e retomar uma migração interrompida. O
`docs/.meta/migracao.md` guarda o plano e, ao final, é reescrito como registro
permanente da estrutura anterior e da correspondência entre caminhos e
identificadores, citado por uma entrada do histórico. Os documentos são movidos com
`git mv` e adaptados ao modelo sem perda de conteúdo. Os identificadores são
renumerados em cada tópico; a preservação dos antigos foi descartada para manter a
numeração contínua, e a correspondência fica no registro. Referências fora de
`docs/` só mudam com aprovação. O interativo direto, sem plano gravado, foi
descartado por não permitir revisão nem retomada.

### TODO e FIXME como itens de pendências

TODO e FIXME do código viram itens de pendências, com arquivo, linha e texto, e o
código não é alterado, o que respeita a regra opcional de documentação no código
autocontida. O `sync` revisa, a cada execução, os TODO/FIXME dos arquivos
alterados: propõe registrar os novos e aponta itens cujo comentário sumiu. Com o
argumento `--todos-completo`, a mesma revisão cobre o repositório inteiro e todas as
pendências abertas; a opção fica no próprio `sync`, e não numa skill `sync-all`,
para manter um único fluxo de reconciliação.

### Glossário opcional na raiz

O glossário é um arquivo único, `docs/glossario.md`, e não um tópico, por ser
geralmente pequeno.
