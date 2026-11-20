---
name: add-topic
description: Adiciona, de forma guiada, um tópico ou subtópico à documentação repo-docs do repositório atual, a partir de um preset ou definido do zero.
disable-model-invocation: true
argument-hint: "[nome-do-topico]"
---

# repo-docs: add-topic

Adiciona um tópico (ou subtópico) a uma documentação já criada por
`/repo-docs:init`.

Recursos do plugin:

- Presets: `${CLAUDE_PLUGIN_ROOT}/presets/` (catálogo em
  `${CLAUDE_PLUGIN_ROOT}/presets/catalogo.md`).
- Verificação: `${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh` e `audit.ps1`.

## 1. Contexto

1. Confirme que `docs/.meta/regras.md` existe; senão, sugira `/repo-docs:init` e
   pare.
2. Leia `docs/.meta/regras.md` (estrutura de tópico, formato de índice, tabela de
   prefixos) e `docs/.meta/index.md`. A pasta `.meta/` pode ser ignorada por buscas
   com Glob/Grep: leia os arquivos pelo caminho.
3. Liste os tópicos existentes (pastas sob `docs/` com `.meta/`).
4. Se a seção Convenções de `docs/.meta/regras.md` não tiver o item "Mensagens de
   commit" (documentação criada antes dessa regra), faça a pergunta **Padrão de
   commits** do `init` e, com a aprovação do usuário, acrescente o item ao fim da
   seção, no formato do catálogo.

## 2. Entrevista

Um item por vez, esperando cada resposta. O nome sugerido é `$ARGUMENTS`, se
informado.

1. **Origem**: um preset do catálogo ainda não usado, ou um tópico novo.
2. **Pai**: a raiz `docs/` ou um tópico existente (para criar um subtópico).
3. Para preset: os subtópicos opcionais, como no `init`. Pule para a etapa 3.
4. Para tópico novo:
   1. **Nome** da pasta, em kebab-case sem acentos, único no pai.
   2. **Propósito**: o que o tópico reúne e por que existe (vira o `README.md` e a
      descrição no índice do pai).
   3. **O que registrar** e o que fica em outros tópicos.
   4. **Identificador**: nenhum, prefixo próprio (2 a 4 letras maiúsculas, ausente
      da tabela de prefixos e de todos os `.meta/regras.md`) ou, para subtópico, o
      prefixo do pai com numeração compartilhada.
   5. **Nome do arquivo**: padrão dos documentos (com identificador, sempre
      `PRE_NNN-titulo-curto.md`) ou, para documentos compostos de vários arquivos,
      um documento em pasta (`PRE_NNN-titulo-curto/`, com arquivos internos
      `PRE_NNN.XX-titulo-curto.md`), conforme a seção Documentos em pasta das
      regras gerais. Neste caso, levante também o modelo do `README.md` da pasta,
      o dos arquivos internos e o das regras da pasta (Identificador
      `` `PRE_NNN.XX` ``), como no preset `tarefas`.
   6. **Modelo**: se os documentos terão estrutura fixa; se sim, levante com o
      usuário os campos de cabeçalho e as seções.
   7. **Descrição no índice**: o que a linha de cada documento deve dizer.
   8. **Ao encerrar**: seção Encerrados com quais desfechos; mover para um
      subtópico (como pendências resolvidas); remover sem registro; ou não se
      aplica.
   9. **Ciclo de vida**: regras adicionais (estados, rastreabilidade, revisões).

Mostre os arquivos que serão criados e alterados e peça confirmação antes de gravar.

## 3. Criação

1. Preset: copie a pasta do preset para o pai, com `.meta/`, substituindo
   `{{PROJETO}}` (nome do projeto, tirado do título de `docs/README.md`) e `{{DATA}}`
   (hoje, `DD/MM/AAAA`).
2. Tópico novo: crie, seguindo o formato dos presets (use
   `${CLAUDE_PLUGIN_ROOT}/presets/decisoes/` como referência):
   - `README.md`: título, propósito e a seção "Por onde começar" com links para o
     índice e as regras;
   - `.meta/index.md`: `# Índice: <nome>` e `- **Atualizado em:** DD/MM/AAAA`;
   - `.meta/regras.md`: `# Regras: <nome>`, o bloco de campos fixos na ordem das
     regras gerais (Identificador, Modelo, Nome do arquivo, Descrição no índice, Ao
     encerrar, Subtópicos), seguido de O que registrar e Ciclo de vida;
   - `.meta/modelo.md`, se houver modelo: `# Modelo de <documento>` e a estrutura
     num bloco de código `markdown`; para documento em pasta, um bloco por modelo
     (use `${CLAUDE_PLUGIN_ROOT}/presets/tarefas/.meta/modelo.md` como referência).
3. No pai:
   - acrescente o item do tópico no `.meta/index.md`, em ordem alfabética, e
     atualize a data;
   - atualize o campo **Subtópicos** do `.meta/regras.md`, se o pai não for a raiz;
   - revise o `README.md`, se ele destacar os subtópicos.
4. Se o tópico tiver prefixo próprio, acrescente a linha na tabela de prefixos de
   `docs/.meta/regras.md`, em ordem alfabética.
5. Se existir `docs/historico/`, registre a criação no arquivo do dia, conforme as
   regras do histórico.

## 4. Verificação

Execute a verificação mecânica a partir da raiz do repositório:

- Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" docs`
- Linux/macOS (ou Git Bash): `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" docs`

Corrija o que for apontado e informe os arquivos criados e alterados. Não faça
commit sem pedido.
