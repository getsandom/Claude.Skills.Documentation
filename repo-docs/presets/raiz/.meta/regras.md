# Regras: documentação

- **Identificador:** nenhum
- **Modelo:** nenhum
- **Nome do arquivo:** não se aplica; a raiz contém apenas os tópicos e, quando houver, o glossário (`glossario.md`)
- **Descrição no índice:** o que o tópico reúne
- **Ao encerrar:** não se aplica
- **Subtópicos:** os tópicos da documentação, listados no [índice](index.md)

Estas regras valem para todos os tópicos. As regras de um tópico complementam as
gerais e, em caso de conflito, prevalecem dentro daquele tópico.

## Estrutura de um tópico

Um tópico é uma pasta que reúne documentos de um mesmo tipo. A raiz `docs/` também
é um tópico, cujos subtópicos são os tópicos da documentação.

```
topico/
├─ README.md          apresentação: o porquê do tópico e os documentos mais relevantes
├─ <documentos>       conteúdo do tópico
├─ <subtopico>/       subtópico, com a mesma estrutura
└─ .meta/
   ├─ index.md        lista de todos os documentos e subtópicos, uma linha por item
   ├─ regras.md       como o tópico funciona: identificador, ciclo de vida, índice
   └─ modelo.md       (opcional) estrutura dos documentos do tópico
```

- Toda subpasta de um tópico, exceto `.meta/`, é um subtópico e tem `README.md` e
  `.meta/` próprios.
- O `README.md` não é um índice: ele apresenta o tópico e aponta para os documentos
  mais relevantes. A lista completa fica em `.meta/index.md`.
- O `.meta/regras.md` começa por um bloco de campos fixos, na ordem abaixo, seguido
  de seções em prosa (O que registrar, Ciclo de vida e o que mais o tópico exigir):
  - **Identificador:** prefixo no formato `PRE_NNN`, ou nenhum;
  - **Modelo:** link para `modelo.md`, ou nenhum;
  - **Nome do arquivo:** padrão do nome dos documentos;
  - **Descrição no índice:** o que a descrição de cada item deve dizer;
  - **Ao encerrar:** o que acontece quando um documento deixa de valer;
  - **Subtópicos:** os subtópicos e o que cada um reúne, ou nenhum.
- A pasta `.meta/` é oculta para algumas ferramentas de busca; leia seus arquivos
  pelo caminho explícito.
- Na raiz, `.meta/migracao.md` existe quando a documentação foi migrada de outro
  formato: durante a migração, contém o plano; depois, o registro do que foi feito,
  com a estrutura anterior e a correspondência entre caminhos e identificadores
  antigos e novos. Caminhos antigos ficam entre crases, sem link. O arquivo não é
  removido nem listado no índice.

## Índices

O `.meta/index.md` de cada tópico lista, em uma linha por item, os documentos de
conteúdo e os subtópicos imediatos, para encontrar um documento sem abrir cada
arquivo.

### O que listar

- Os documentos de conteúdo e os subtópicos imediatos do tópico.
- O `README.md` e os arquivos de `.meta/` não entram na lista.
- Ordem alfabética do nome (ordem de bytes), que nos tópicos com identificador
  coincide com a ordem numérica e, no histórico, com a ordem cronológica.
- Documentos com identificador removidos continuam listados na seção Encerrados (ver
  [Documentos encerrados](#documentos-encerrados)), salvo quando as regras do tópico
  determinarem outro destino.

### Formato de cada item

```markdown
- [nome-do-arquivo.md](../nome-do-arquivo.md): Descrição.
```

- O texto do link é o nome exato do arquivo, com extensão; para subtópicos, o nome
  seguido de barra (`subtopico/`). O destino é relativo à pasta `.meta/`, por isso
  começa por `../`.
- A descrição diz do que o documento trata e o ponto principal do conteúdo, sem
  apenas repetir o título, conforme o campo **Descrição no índice** das regras do
  tópico.
- Tamanho: preferencialmente entre 200 e 300 caracteres, nunca mais de 500.
- Uma ou duas frases, sem listas nem quebras de linha dentro da descrição.

### Documentos encerrados

Quando um documento com identificador é removido, sua linha sai da lista vigente e
passa para a seção `## Encerrados`, ao final do índice. Assim o identificador
continua localizável depois que o arquivo deixa de existir, por exemplo quando é
citado em um commit ou no histórico.

```markdown
- `PRE_NNN-titulo.md`: Desfecho em DD/MM/AAAA. Descrição.
```

- O nome do arquivo fica entre crases, sem link, porque o arquivo não existe mais.
- A descrição começa pelo desfecho, conforme as regras do tópico, e pela data; em
  seguida, uma lembrança do conteúdo e para onde ele foi, com link para o destino
  quando houver.
- Mesmos limites de tamanho dos demais itens, em ordem numérica.
- A seção só existe quando houver ao menos um item, e seus itens não são removidos.

### Estrutura do arquivo

```markdown
# Índice: nome do tópico

- **Atualizado em:** DD/MM/AAAA

- [PRE_001-titulo.md](../PRE_001-titulo.md): Descrição.
- [subtopico/](../subtopico/): Descrição.

## Encerrados

- `PRE_002-titulo.md`: Desfecho em DD/MM/AAAA. Descrição.
```

### Manutenção

O índice é atualizado junto com o tópico: ao criar, remover, mover ou renomear um
documento, ou quando uma mudança de conteúdo deixar a descrição incorreta; a data
**Atualizado em** acompanha cada alteração. Atualizar o índice não precisa de
entrada no histórico. O `README.md` do tópico é revisto quando os documentos que ele
destaca mudarem.

## Identificadores

Os tópicos com identificador numeram seus documentos com um prefixo próprio, um
sublinhado e três dígitos (`PRE_NNN`). Um subtópico só usa o prefixo do tópico pai
quando suas regras disserem que compartilha a numeração.

| Prefixo | Tópico |
|---|---|

- O identificador inicia o nome do arquivo (`PRE_004-titulo-curto.md`) e o título
  (`# PRE_004: ...`).
- O próximo identificador é o maior número já usado com o prefixo mais um,
  considerando os arquivos, os subtópicos que compartilham o prefixo e as seções
  Encerrados. Números não são reutilizados.
- Links para esses documentos trazem o identificador no texto, seguido de um resumo
  (por exemplo, `[PRE_004: título](caminho/PRE_004-titulo.md)`).
- Commits e pull requests que tratam de um tópico citam o identificador (por
  exemplo, "resolve PRE_010").

### Documentos em pasta

Quando o campo **Nome do arquivo** de um tópico definir uma pasta por documento, o
documento é um subtópico:

- O identificador inicia o nome da pasta (`PRE_004-titulo-curto/`), que tem
  `README.md`, com o título iniciado pelo identificador (`# PRE_004: ...`), e
  `.meta/` próprios.
- Os arquivos internos numerados usam um sub-identificador, o identificador da
  pasta seguido de ponto e dois dígitos, a partir de `01` (`PRE_004.01`). O campo
  **Identificador** das regras da pasta o declara como `` `PRE_NNN.XX` ``; o nome
  do arquivo começa por ele (`PRE_004.01-titulo-curto.md`) e o título também
  (`# PRE_004.01: ...`).
- Os demais arquivos da pasta são de apoio e não começam pelo identificador.
- O próximo sub-identificador é o maior `XX` usado na pasta mais um.
- Commits e pull requests que tratam de um arquivo interno citam o
  sub-identificador (por exemplo, "PRE_004.02").

## Como documentar

1. Escolha o tópico pelo tipo do assunto, conforme a seção O que registrar das
   regras de cada tópico.
2. Siga o `modelo.md` do tópico, quando houver.
3. Dê ao documento o próximo identificador livre, quando o tópico tiver
   identificador.
4. Mantenha o documento atual: edite-o quando algo mudar, em vez de acrescentar
   versões. Quando ele deixar de valer, siga o campo **Ao encerrar** das regras do
   tópico e leve o conteúdo relevante para onde ele passa a viver.
5. Atualize o `.meta/index.md` do tópico e, se for o caso, o `README.md`.
6. Registre no histórico as decisões e ações relevantes (ver [Histórico](#histórico)).

## Histórico

Quando existir o tópico `historico/`, as criações, mudanças de conteúdo e remoções
de documentos são registradas no arquivo do dia, conforme as regras daquele tópico.
Correções de digitação e formatação e atualizações de índice não precisam de
registro.

## Convenções

- Datas no formato `DD/MM/AAAA` e horas no formato `HH:MM` (00:00 a 23:59).
- Arquivos e pastas em kebab-case, sem acentos, precedidos do identificador quando
  houver.
- Referências entre documentos por link relativo.
- Termos do domínio em português, como no glossário, quando houver; classes e
  métodos pelo nome no código, entre crases.
- Tom formal.
- Mensagens de commit: {{COMMITS}}.

<!-- repo-docs:opcional documentacao-no-codigo -->
## Documentação no código

A documentação escrita no próprio código (comentários e documentação de API) é
autocontida e não substitui esta pasta:

- Explica como o código funciona ou como usá-lo: comportamento, parâmetros,
  retornos, exceções e restrições de uso.
- Referencia apenas elementos do próprio código (tipos, membros, parâmetros).
- Não referencia documentos desta pasta (identificadores, caminhos ou links) nem
  registra o porquê de decisões. A motivação fica na decisão, no documento de
  arquitetura ou na pendência correspondente.
<!-- /repo-docs:opcional documentacao-no-codigo -->
