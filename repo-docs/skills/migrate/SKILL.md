---
name: migrate
description: Localiza a documentação existente no repositório (docs/ em outro formato, Markdown espalhado, seções de README.md e CLAUDE.md, TODO/FIXME no código) e a migra para a estrutura repo-docs, por inventário, plano revisável e execução registrada em docs/.meta/migracao.md.
disable-model-invocation: true
argument-hint: "[caminho a inventariar]"
---

# repo-docs: migrate

Migra a documentação existente para a estrutura repo-docs em três fases:
inventário, plano e execução. O arquivo `docs/.meta/migracao.md` guarda o plano e,
depois, o registro do que foi feito.

Recursos do plugin:

- Inventário: `${CLAUDE_PLUGIN_ROOT}/skills/migrate/scripts/inventory.sh` e
  `inventory.ps1` (só leitura; uso no cabeçalho de cada script).
- Próximo identificador e verificação: `${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh`
  e `audit.ps1`.
- Criação da estrutura: as instruções de `${CLAUDE_PLUGIN_ROOT}/skills/init/SKILL.md`
  e `${CLAUDE_PLUGIN_ROOT}/skills/add-topic/SKILL.md`.

Comandos, a partir da raiz do repositório (Windows: `powershell -NoProfile
-ExecutionPolicy Bypass -File "<script>.ps1"` com `-Markdown`, `-Todos`, `-Refs`,
`-NextId`; Linux/macOS ou Git Bash: `bash "<script>.sh"` com `--markdown`,
`--todos`, `--refs`, `--next-id`).

Regras gerais:

- Pergunte um item por vez e espere a resposta. Nada fora de `docs/` é alterado sem
  aprovação explícita; nenhum conteúdo é descartado sem aprovação e registro.
- Mova arquivos com `git mv`, para preservar o histórico; fora de um repositório
  git, mova normalmente e registre isso.
- Datas e horas vêm do relógio do sistema (`date`, `Get-Date`), nunca estimadas.
- Se `docs/.meta/migracao.md` existir com itens pendentes, a migração foi
  interrompida: retome a partir do primeiro item pendente.
- Não faça commit sem pedido. Sugira commits por fase (estrutura, cada tópico,
  registro) quando o usuário pedir.

## 1. Inventário (só leitura)

Sobre o repositório inteiro ou sobre `$ARGUMENTS`, quando informado:

1. `inventory --markdown`: documentos de texto fora da documentação estruturada.
   Uma pasta `docs/` sem `.meta/regras.md` é documentação legada e entra no
   inventário.
2. `README.md` e `CLAUDE.md` da raiz e de subprojetos: leia por seções e marque as
   que descrevem decisões, arquitetura, requisitos, operação ou pendências. Seções
   de apresentação, instalação rápida e instruções ao agente permanecem.
3. `inventory --todos`: TODO e FIXME no código.
4. Para cada documento, determine:
   - o tópico de destino, entre os presets do catálogo
     (`${CLAUDE_PLUGIN_ROOT}/presets/catalogo.md`) e os tópicos existentes, ou um
     tópico novo quando nenhum couber;
   - a ação: **mover** (o arquivo inteiro vira um documento), **dividir** (um
     arquivo com vários assuntos vira vários documentos), **extrair** (seção de
     README ou CLAUDE.md), **mesclar** (o conteúdo complementa um documento já
     existente), **descartar** (sem conteúdo útil; exige aprovação) ou **manter**
     (fica onde está, por exemplo um `README.md` de pacote);
   - o identificador antigo, quando houver (`DEC_004`, `ADR-0007`, `0007-` no nome);
   - o estado ou desfecho, quando houver (decisão substituída, pendência resolvida,
     melhoria implementada), para levar o documento ao lugar certo.
5. Agrupe TODO/FIXME por assunto: cada grupo vira uma pendência nova (tipo Defeito
   ou Débito técnico) ou itens de uma pendência existente. Ocorrências triviais ou
   obsoletas podem ser ignoradas, com aprovação.
6. Para cada identificador antigo e cada caminho de documento movido, rode
   `inventory --refs <padrão>` para localizar as referências fora de `docs/`.

Apresente um resumo do inventário (quantidades por fonte e por tópico, ambiguidades)
e esclareça as ambiguidades com o usuário antes de seguir.

## 2. Estrutura

1. Se existir `docs/` legado, proponha `git mv docs docs-legado`, para liberar
   `docs/` para a nova estrutura. Grave só com aprovação.
2. Se `docs/.meta/regras.md` não existir, execute o fluxo do `init`, sugerindo os
   tópicos que o inventário indicou; tópicos novos seguem o fluxo do `add-topic`.
   Se a estrutura já existir, crie apenas os tópicos que faltarem.
3. Prefixos de identificador de tópicos novos não podem coincidir com os antigos de
   outra natureza, para não confundir referências históricas.

## 3. Plano

Grave `docs/.meta/migracao.md` neste formato (caminhos antigos sempre entre crases,
sem link, porque deixarão de existir):

```markdown
# Migração da documentação

- **Fase:** Plano | Em execução | Concluída
- **Iniciada em:** DD/MM/AAAA
- **Atualizado em:** DD/MM/AAAA

## Itens

| Nº | Origem | Ação | Destino | ID antigo | ID novo | Estado |
|---|---|---|---|---|---|---|
| 1 | `docs-legado/decisoes/DEC_004-x.md` | mover | `decisoes/` | DEC_004 | DEC_001 | Pendente |

## TODO e FIXME

| Grupo | Ocorrências | Destino | Estado |
|---|---|---|---|

## Referências fora de docs/

| Arquivo:linha | Referência | Substituição | Estado |
|---|---|---|---|
```

- Os identificadores novos são renumerados em cada tópico, preservando a ordem
  relativa dos identificadores antigos de mesmo prefixo (`DEC_004` antes de
  `DEC_005`). Documentos de fontes diferentes (ADRs, Markdown sem identificador)
  entram pela data de criação, quando conhecida (campo de data do documento ou
  primeiro commit, `git log --diff-filter=A --format=%as -- <arquivo>`), e no fim,
  em ordem alfabética, quando não for. A data de atualização não define a ordem. Obtenha o primeiro com `audit --next-id PRE` e incremente na ordem do
  plano. Documentos encerrados na origem também recebem número e vão para a seção
  Encerrados ou para o subtópico de destino, conforme as regras do tópico.
- Estados: Pendente, Feito, Ignorado (com o motivo na coluna Destino) e, para
  referências, Recusado.

Mostre o plano e peça aprovação em bloco ou item a item; ajuste o arquivo conforme
as respostas.

## 4. Execução

Atualize **Fase** para "Em execução" e, a cada item concluído, o estado na tabela.

1. **Mover**: `git mv` para o destino com o nome no padrão do tópico; adapte ao
   modelo sem perder conteúdo: título com o identificador novo, campos do
   cabeçalho (datas do conteúdo antigo quando houver, senão a data de hoje),
   seções renomeadas para as do modelo. O que não couber em nenhuma seção vai para
   Observações (ou a última seção do modelo). O identificador antigo não é citado
   no documento; ele fica em `migracao.md`.
2. **Dividir** e **extrair**: crie os documentos de destino com o trecho
   correspondente. Na origem (README.md, CLAUDE.md), substitua a seção por uma
   frase com link para o destino, com aprovação.
3. **Mesclar**: acrescente o conteúdo no documento existente, na seção adequada.
4. **TODO/FIXME**: crie ou atualize as pendências, com uma linha por ocorrência na
   seção Itens, no formato `` - `caminho:linha`: `texto` ``, em que `texto` é a
   linha exatamente como o script de inventário a imprime (sem corrigir grafia nem
   acentos), opcionalmente seguida de "; efeito: ...". O código não é alterado.
5. **Links e identificadores dentro de `docs/`**: depois de cada tópico, atualize
   os links relativos e as menções a identificadores antigos em todos os documentos
   migrados, inclusive no histórico migrado.
6. **Referências fora de `docs/`**: aplique as substituições aprovadas; as recusadas
   ficam registradas.
7. Índices e READMEs dos tópicos, conforme as regras gerais.

Depois de cada tópico, execute o `audit` e corrija o que for apontado.

## 5. Registro

Ao concluir (ou ao interromper por decisão do usuário), reescreva
`docs/.meta/migracao.md` como registro do que foi feito, para preservar o que a
migração eliminou:

```markdown
# Migração da documentação

- **Fase:** Concluída
- **Iniciada em:** DD/MM/AAAA
- **Concluída em:** DD/MM/AAAA

## Resumo

Fontes migradas, quantidade de documentos por tópico e o que ficou de fora.

## Estrutura anterior

Árvore resumida das fontes de documentação antes da migração, com o papel de cada
pasta ou arquivo e convenções que deixaram de valer (prefixos, modelos, índices).

## Correspondência

| Origem | ID antigo | Destino | ID novo |
|---|---|---|---|

## Seções extraídas

| Arquivo de origem | Seção | Destino |
|---|---|---|

## TODO e FIXME

| Ocorrências | Pendência |
|---|---|

## Referências fora de docs/

| Arquivo | Referência antiga | Situação (atualizada, recusada) |
|---|---|---|

## Itens não migrados

| Origem | Motivo |
|---|---|
```

- Destinos com link relativo (a partir de `docs/.meta/`); origens entre crases.
- Remova `docs-legado/` quando estiver vazio; se sobrar algo, liste em Itens não
  migrados e pergunte o que fazer.
- Registre no histórico do dia uma entrada (tipo Alteração) "Migração da
  documentação", com link para `../.meta/migracao.md` e o resumo.
- Execute o `audit` final e mostre o resultado; o esperado é
  `Resumo: 0 erro(s), 0 aviso(s).`
- Confira que nenhum arquivo de origem se perdeu: o número de documentos
  inventariados é igual à soma dos migrados, mesclados, mantidos e não migrados.
