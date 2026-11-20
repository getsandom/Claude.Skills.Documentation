---
name: init
description: Cria a estrutura de documentação repo-docs (pasta docs/ organizada em tópicos com README.md e .meta/) no repositório atual, entrevistando o usuário sobre os tópicos desejados.
disable-model-invocation: true
argument-hint: "[nome do projeto]"
---

# repo-docs: init

Cria `docs/` no repositório atual a partir dos presets do plugin, conforme as
escolhas do usuário.

Recursos do plugin:

- Presets: `${CLAUDE_PLUGIN_ROOT}/presets/` (catálogo em
  `${CLAUDE_PLUGIN_ROOT}/presets/catalogo.md`; leia-o antes de começar).
- Verificação: `${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh` e `audit.ps1`.

## 1. Pré-condições

1. Identifique a raiz do repositório (`git rev-parse --show-toplevel`; sem git, o
   diretório atual) e confirme com o usuário se houver dúvida.
2. Se `docs/.meta/regras.md` existir, a estrutura já foi criada: informe e sugira
   `/repo-docs:add-topic` ou `/repo-docs:audit`. Pare.
3. Se `docs/` existir sem `docs/.meta/`, há documentação em outro formato: informe o
   que existe e sugira `/repo-docs:migrate`, que inventaria e migra a documentação
   existente. Pare; nunca sobrescreva nem mova arquivos sem aprovação explícita.
4. Se houver outra documentação no repositório (ADRs, Markdown espalhado, seções
   de decisão ou arquitetura no `README.md`), mencione ao final que
   `/repo-docs:migrate` pode trazê-la para a nova estrutura.

## 2. Entrevista

Pergunte um item por vez (com AskUserQuestion, quando disponível), esperando cada
resposta:

1. **Nome do projeto**: `$ARGUMENTS`, se informado; senão, sugira o nome da pasta do
   repositório.
2. **Tópicos**: seleção múltipla entre os presets do catálogo, todos recomendados.
   Informe as dependências do catálogo (por exemplo, `scripts` pressupõe `suporte`).
3. **Subtópicos opcionais**: para cada tópico escolhido com subtópico opcional
   (hoje, `arquitetura/dominio/`), pergunte se deve ser incluído. Subtópicos
   obrigatórios (`pendencias/resolvidas/`, `requisitos/usuario/` e `sistema/`,
   `tarefas/concluidas/`) são sempre copiados.
4. **Glossário**: incluir `docs/glossario.md`?
5. **Documentação no código**: incluir a regra de documentação no código autocontida
   nas regras gerais?
6. **Padrão de commits**: o padrão das mensagens de commit, que vai para as
   Convenções das regras gerais. Leia as mensagens recentes
   (`git log --no-merges --format=%s -n 50`):
   - com histórico, descreva o padrão predominante com dois ou três exemplos reais e
     proponha-o;
   - sem histórico, sem padrão identificável ou sem preferência do usuário, proponha
     Conventional Commits (`tipo(escopo): resumo`);
   - o usuário pode definir outro padrão.
7. **Tópicos próprios**: o usuário quer criar outros tópicos agora? Se sim, anote e
   execute o fluxo de `/repo-docs:add-topic` para cada um depois da etapa 3.

Em seguida, mostre a árvore resultante e peça confirmação antes de gravar.

## 3. Criação

1. Copie `presets/raiz/` (incluindo `.meta/`) para `docs/`, sem `glossario.md` se
   ele não foi escolhido.
2. Copie cada preset escolhido para `docs/<preset>/`, recursivamente, incluindo as
   pastas `.meta/`; omita os subtópicos opcionais recusados.
3. Em todos os arquivos copiados, substitua `{{PROJETO}}` pelo nome do projeto e
   `{{DATA}}` pela data de hoje em `DD/MM/AAAA`. Confira que nenhum `{{` restou.
4. Em `docs/.meta/regras.md`:
   - preencha a tabela de prefixos com uma linha por tópico com identificador
     (`| \`DEC\` | [decisoes](../decisoes/) |`), em ordem alfabética do prefixo;
     subtópicos que compartilham o prefixo do pai não ganham linha;
   - mantenha ou remova o bloco opcional de documentação no código conforme a
     resposta (ver catálogo);
   - substitua `{{COMMITS}}` pela descrição do padrão de commits escolhido, com um
     exemplo (ver catálogo).
5. Em `docs/.meta/index.md`, acrescente um item por tópico escolhido e, se for o
   caso, pelo glossário, com a descrição do catálogo, em ordem alfabética do nome,
   no formato `- [decisoes/](../decisoes/): Descrição.`
6. Se `arquitetura/dominio/` foi incluído, acrescente o item dele em
   `docs/arquitetura/.meta/index.md`; se foi recusado, verifique que nenhum arquivo
   copiado o referencia.
7. Se `historico` foi escolhido, crie `docs/historico/AAAA-MM-DD.md` com a entrada
   de criação da estrutura (tipo Criação, documentos `docs/README.md` e os tópicos,
   motivo "Criação da estrutura de documentação pelo repo-docs.") conforme
   `docs/historico/.meta/modelo.md`, e o item correspondente no índice do histórico.
   Datas e horas vêm do relógio do sistema (`date` no bash, `Get-Date` no
   PowerShell), nunca estimadas.

## 4. CLAUDE.md

Proponha o trecho abaixo para o `CLAUDE.md` da raiz do repositório (criando o arquivo
se não existir), mostre-o e grave só com aprovação explícita. Se já houver uma seção
sobre documentação, proponha a mesclagem em vez de duplicar.

```markdown
## Documentação (`docs/`)

A documentação segue a estrutura repo-docs: cada tópico é uma pasta com `README.md`
(apresentação), documentos de conteúdo e `.meta/` (`index.md`, `regras.md` e, quando
houver, `modelo.md`). Antes de criar ou alterar documentos, leia `docs/README.md`,
`docs/.meta/regras.md` e o `.meta/regras.md` do tópico; a pasta `.meta/` é oculta
para algumas buscas, então leia-a pelo caminho. Mantenha o índice do tópico e o
histórico atualizados.
```

## 5. Verificação

Execute a verificação mecânica a partir da raiz do repositório e mostre o resultado:

- Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" docs`
- Linux/macOS (ou Git Bash): `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" docs`

O resultado esperado é `Resumo: 0 erro(s), 0 aviso(s).`. Corrija o que for apontado
antes de concluir e informe os arquivos criados. Não faça commit sem pedido.
