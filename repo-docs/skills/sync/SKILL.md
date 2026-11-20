---
name: sync
description: Mantém a documentação repo-docs consistente ao criar, alterar, encerrar, mover ou renomear documentos em docs/ (próximo identificador, índice .meta/index.md, README do tópico, histórico do dia) e revisa os TODO/FIXME dos arquivos alterados contra as pendências. Use sempre que for registrar uma decisão, pendência, melhoria, requisito, tarefa ou outro documento em um repositório cuja pasta docs/ tenha .meta/regras.md, ao planejar ou executar os passos de uma tarefa, ou ao resolver uma pendência e revogar uma decisão.
argument-hint: "[operação e documento] [--todos-completo]"
---

# repo-docs: sync

Aplica as regras da documentação a uma mudança em `docs/`, seja pedida pelo usuário
(`$ARGUMENTS`), seja parte de outra tarefa.

Recursos do plugin:

- Próximo identificador e verificação: `${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh`
  e `audit.ps1`.

## 1. Regras

1. Leia `docs/.meta/regras.md` (regras gerais) e o `.meta/regras.md` do tópico
   afetado, além do `.meta/modelo.md`, quando houver. As regras do tópico
   prevalecem sobre as gerais.
2. A pasta `.meta/` pode ser ignorada por buscas com Glob/Grep: leia os arquivos
   pelo caminho explícito.
3. Se não estiver claro em qual tópico o assunto se encaixa, use a seção O que
   registrar das regras de cada tópico e, persistindo a dúvida, pergunte.

## 2. Operações

### Criar documento

1. Com identificador, obtenha o próximo número livre pelo script, a partir da raiz
   do repositório:
   - `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" --next-id PRE docs`
   - `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" -NextId PRE docs`
2. Nomeie o arquivo pelo campo **Nome do arquivo** e preencha o modelo; o título
   começa pelo identificador (`# PRE_NNN: ...`).
3. Ligue os documentos relacionados nos dois sentidos quando as regras pedirem
   (por exemplo, **Detalha**/**Detalhado por** em requisitos).

### Criar documento em pasta

Quando o campo **Nome do arquivo** do tópico definir uma pasta por documento (por
exemplo, tarefas), conforme a seção Documentos em pasta das regras gerais:

1. Siga a seção Antes de planejar (ou equivalente) das regras do tópico antes de
   escrever qualquer arquivo.
2. Obtenha o identificador como em Criar documento e crie a pasta
   `PRE_NNN-titulo-curto/` com:
   - `README.md` pelo modelo do tópico, com o título `# PRE_NNN: ...`;
   - `.meta/regras.md` pelo modelo das regras da pasta, com o Identificador
     `` `PRE_NNN.XX` ``;
   - `.meta/index.md` com os arquivos internos e os de apoio.
3. Numere os arquivos internos pelo script, com o identificador da pasta:
   - `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" --next-id PRE_NNN docs`
   - `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" -NextId PRE_NNN docs`
4. A pasta entra no índice do tópico como subtópico
   (`- [PRE_NNN-titulo/](../PRE_NNN-titulo/): Descrição.`).

### Alterar documento

Edite o conteúdo para refletir o estado atual (sem acrescentar versões) e atualize
**Atualizado em**. Se a descrição no índice deixar de estar correta, reescreva-a.

Num documento em pasta, a mudança de um arquivo interno (por exemplo, o estado de um
passo) atualiza também o `README.md` da pasta, como as regras do tópico pedirem
(seção Passos e estado da tarefa), e a descrição da pasta no índice do tópico, se
ela deixar de estar correta.

### Encerrar documento

Siga o campo **Ao encerrar** do tópico:

- **Seção Encerrados**: remova o arquivo e mova a linha para `## Encerrados` no fim
  do índice (criando a seção se preciso), com o nome entre crases sem link e a
  descrição iniciada pelo desfecho e pela data, em ordem numérica.
- **Mover para subtópico** (ex.: pendência resolvida, tarefa concluída): preencha o
  que as regras pedem (seção Resolução, seções Conclusão), mova o arquivo ou a
  pasta, corrija os links relativos dele e os links de outros documentos para ele,
  e mova a linha para o índice do subtópico com a descrição reescrita. Ao mover uma
  pasta, a profundidade muda: corrija os links de todos os arquivos dela que saem
  da pasta (inclusive os de `.meta/`).
- **Remover**: remova o arquivo e a linha do índice.

Em todos os casos, leve o conteúdo que continua valendo para onde ele passa a viver
e corrija os links de outros documentos para o arquivo removido.

### Mover ou renomear

Mova o arquivo, atualize os índices de origem e de destino e corrija os links que
apontam para ele, inclusive no histórico.

## 3. Índice, README e histórico

1. Atualize o `.meta/index.md` do tópico: um item por documento, no formato e no
   tamanho das regras gerais, em ordem alfabética, e a data **Atualizado em**.
2. Revise o `README.md` do tópico quando os documentos que ele destaca mudarem; ele
   não lista todos os documentos.
3. Se existir `docs/historico/`, registre criações, mudanças de conteúdo e remoções
   no arquivo do dia (`AAAA-MM-DD.md`), conforme as regras do histórico, criando o
   arquivo e o item no índice do histórico se preciso. Atualizações de índice e
   correções de formatação não são registradas.
4. Datas e horas vêm do relógio do sistema, nunca estimadas: `date +%d/%m/%Y`,
   `date +%H:%M` e `date +%F` (bash) ou `Get-Date -Format dd/MM/yyyy`,
   `Get-Date -Format HH:mm` e `Get-Date -Format yyyy-MM-dd` (PowerShell).

## 4. Revisão de TODO e FIXME

Se existir o tópico `pendencias/`, revise as pendências anotadas no código. Há dois
escopos:

- **Arquivos alterados** (padrão, a cada execução): os arquivos de
  `git diff --name-only HEAD` e `git ls-files --others --exclude-standard`. Fora de
  um repositório git, este escopo é pulado.
- **Repositório inteiro**: quando `$ARGUMENTS` contiver `--todos-completo` ou o
  usuário pedir a revisão de todo o código. Pode ser executado sozinho, sem outra
  operação de documento.

Passos:

1. Liste as ocorrências com o script de inventário, a partir da raiz do
   repositório. No escopo de arquivos alterados, passe os arquivos; no do
   repositório inteiro, não passe nenhum:
   - `bash "${CLAUDE_PLUGIN_ROOT}/skills/migrate/scripts/inventory.sh" --todos [arquivos...]`
   - `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/migrate/scripts/inventory.ps1" -Todos [arquivos...]`
2. Compare com a seção Itens das pendências abertas (`docs/pendencias/*.md`), pelo
   arquivo e pelo texto do comentário (a linha pode ter mudado):
   - ocorrência que nenhuma pendência cita: proponha registrá-la, como item de uma
     pendência existente do mesmo assunto ou numa pendência nova, no formato
     `` - `caminho:linha`: `texto` ``, em que `texto` é a linha exatamente como o
     script a imprime (sem corrigir grafia nem acentos), opcionalmente seguida de
     "; efeito: ..." com o efeito no sistema;
   - item de pendência cujo comentário não existe mais no arquivo citado: aponte-o
     e proponha atualizar a pendência (ou resolvê-la, se não restar item). No
     escopo de arquivos alterados, verifique só os itens que citam esses arquivos;
     no do repositório inteiro, todos os itens de todas as pendências abertas;
   - item cuja linha mudou: proponha atualizar o número da linha.
3. No repositório inteiro, apresente primeiro um resumo (ocorrências não
   registradas por pasta, itens sem comentário, linhas desatualizadas) e proponha
   os registros agrupados por assunto, para aprovação em bloco ou por grupo.
   Ocorrências triviais ou obsoletas podem ser deixadas de fora, com aprovação.
4. Registre só com aprovação. O código não é alterado: o comentário permanece e a
   pendência indica onde ele está.

## 5. Verificação

Ao terminar, execute a verificação mecânica e corrija o que for apontado:

- `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" docs`
- `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" docs`

Informe os arquivos criados, alterados e removidos e o identificador usado. Não faça
commit sem pedido; quando o usuário pedir, a mensagem segue o item "Mensagens de
commit" das Convenções das regras gerais e cita o identificador. Se o item não
existir, pergunte o padrão ao usuário, como no `init`, e proponha acrescentá-lo.
