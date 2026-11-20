# Regras: tarefas

- **Identificador:** `TAR_NNN` (compartilha a numeração com `concluidas/`)
- **Modelo:** [modelo.md](modelo.md)
- **Nome do arquivo:** uma pasta por tarefa, `TAR_NNN-titulo-curto/` (ex.: `TAR_001-citacoes-no-codigo/`), e dentro dela um arquivo por passo, `TAR_NNN.XX-titulo-curto.md` (ex.: `TAR_001.01-inventario-das-decisoes.md`)
- **Descrição no índice:** o objetivo da tarefa e o estado, com o passo atual ou o bloqueio
- **Ao encerrar:** preencher a Conclusão dos passos e do README da tarefa e mover a pasta para `concluidas/`, corrigindo os links relativos dela e os de outros documentos para ela
- **Subtópicos:** uma pasta por tarefa em andamento e `concluidas/`, as tarefas concluídas

## O que registrar

Uma tarefa registra o plano e a execução de um trabalho extenso e contíguo, em
vários passos, planejado para ser executado por agentes de IA quase em sequência e
que precisa poder ser interrompido e retomado. Ela não substitui os outros tópicos:

- o problema que motiva a tarefa fica numa pendência, com link para a tarefa;
- as escolhas feitas no caminho ficam nas decisões ou no documento onde o resultado
  passa a valer;
- a tarefa guarda o como: os passos, os limites, o que cada passo entrega ao
  seguinte e o que foi encontrado.

### Pendência ou tarefa

- Uma pendência é um item em aberto que em algum momento precisará ser trabalhado,
  seja uma decisão, seja uma implementação no código. Ela é objetiva e trata apenas
  do essencial para o trabalho em questão, cuja execução costuma poder ser inferida
  pelo próprio escopo.
- Uma tarefa é um plano extenso e contíguo de execução para agentes de IA, com os
  passos planejados antes e executados quase em sequência.
- Um trabalho pequeno, de um ou dois passos, é uma pendência, não uma tarefa.
- Uma pendência grande não vira tarefa por ser grande: ela é dividida em várias
  pendências distintas.
- Uma pendência só vira tarefa quando o usuário pedir explicitamente e os passos de
  execução forem planejados.

## Antes de planejar

1. Verifique o tamanho do escopo. Se ele previr só um ou dois passos, pergunte ao
   usuário se deseja mesmo criar a tarefa, propondo registrar o trabalho numa
   pendência em vez dela; a tarefa só é criada com a confirmação do usuário.
2. Resolva as ambiguidades entrevistando o usuário, uma questão por vez, antes de
   escrever os passos.

## Estrutura da tarefa

```
TAR_NNN-titulo-curto/
├─ README.md                     documento central: escopo, proposta, passos e conclusão
├─ TAR_NNN.01-titulo-curto.md    primeiro passo
├─ TAR_NNN.02-titulo-curto.md    segundo passo
├─ <arquivos de apoio>           inventários, listas e resultados usados pelos passos
└─ .meta/
   ├─ index.md                   os passos e os arquivos de apoio
   └─ regras.md                  aponta estas regras como base e define extensões e sobrescritas
```

- A tarefa é um documento em pasta, conforme as regras gerais: o `README.md` começa
  por `# TAR_NNN:` e cada passo, por `# TAR_NNN.XX:`.
- O `README.md` segue o modelo do README da tarefa e cada passo segue o modelo do
  passo, em [modelo.md](modelo.md); uma sobrescrita nas regras da tarefa pode
  alterá-los.
- `XX` tem dois dígitos, começa em `01` em cada tarefa e dá a ordem de execução
  (`01`, `02`, ..., `10`, `11`).
- Os arquivos de apoio não começam pelo identificador; a convenção do nome deles
  fica nas regras da tarefa.
- O `.meta/regras.md` da tarefa segue o modelo das regras da tarefa, em
  [modelo.md](modelo.md):
  - aponta para estas regras como a fonte original e a base da tarefa: tudo o que
    as regras da tarefa não especificarem segue estas regras;
  - as regras próprias da tarefa podem estender estas regras ou sobrescrever um
    ponto delas; cada sobrescrita nomeia a regra deste tópico que substitui e diz
    por quê, e o resto daquela regra continua valendo;
  - exemplos de regras próprias: a ordem dos lotes, o que não pode ser alterado, a
    convenção dos arquivos de apoio.
- O `.meta/index.md` da tarefa lista os passos e os arquivos de apoio, no formato
  das regras gerais.

## Ciclo de vida da tarefa

- **Estado:** `Planejada`, `Em execução`, `Bloqueada` ou `Concluída`, no cabeçalho
  do README da tarefa e na descrição dela no índice.
- Quando todos os passos estiverem concluídos, a Conclusão do README é preenchida e
  a pasta vai para `concluidas/`, com a linha movida para o índice daquele
  subtópico.

## Ciclo de vida do passo

- **Estado:** `Pendente`, `Em execução`, `Bloqueado` ou `Concluído`, no cabeçalho do
  passo.
- Antes de iniciar um passo, confira os Bloqueios dele. Faltando algum, o passo fica
  `Bloqueado`, o que falta é registrado e a execução para.
- Ao terminar, o passo fica `Concluído`, com a seção Conclusão preenchida: o que foi
  decidido, executado ou encontrado no código.
- O passo nunca sai da pasta da tarefa, em nenhum estado.
- Toda mudança de estado de um passo atualiza a seção Passos do README da tarefa e,
  se for o caso, o estado da tarefa.
- Commits e pull requests de um passo seguem o padrão de commits das regras gerais e
  citam o identificador dele (por exemplo, "TAR_001.02").
