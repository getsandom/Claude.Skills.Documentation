# Modelo de tarefa

Três modelos: o README da tarefa, o passo e as regras da tarefa.

## README da tarefa

```markdown
# TAR_NNN: Título da tarefa

- **Estado:** Planejada | Em execução | Bloqueada | Concluída
- **Origem:** link para a pendência, ou o pedido do usuário com a data
- **Atualizado em:** DD/MM/AAAA

## Escopo

O que a tarefa cobre e o que fica de fora, em resumo.

## Proposta

Como a tarefa resolve o escopo: a abordagem e as decisões que ela segue, com link.

## Passos

- [TAR_NNN.01: título](TAR_NNN.01-titulo-curto.md): Pendente | Em execução | Bloqueado | Concluído
- [TAR_NNN.02: título](TAR_NNN.02-titulo-curto.md): Pendente

## Conclusão

Enquanto a tarefa não termina, "Ainda não concluída.". Depois: o resultado geral,
onde ele passou a valer (decisões, documentos, código) e o que ficou para outra
pendência ou tarefa.
```

## Passo

```markdown
# TAR_NNN.XX: Título do passo

- **Estado:** Pendente | Em execução | Bloqueado | Concluído
- **Depende de:** TAR_NNN.XX, ou nenhum
- **Próximo:** TAR_NNN.XX, ou nenhum
- **Atualizado em:** DD/MM/AAAA

## Contexto

O que ler antes de começar: documentos, arquivos de código e seções relevantes, com
link, e o que cada um traz para o passo.

## Bloqueios

O que precisa estar resolvido antes de iniciar: decisões do usuário, passos
anteriores, acessos, dados. Confira cada item antes de começar; faltando qualquer
um, registre aqui o que falta, mude o estado para Bloqueado e pare. Sem
impedimentos, "Nenhum.".

## Ação

O que fazer, em itens numerados (1, 2, ...), com os arquivos, os tipos e as regras
envolvidos.

## Limites

O que o passo não deve fazer: o que fica para outro passo, o que não pode ser
alterado, as abordagens descartadas.

## Critério de sucesso

Como saber que o passo terminou: verificações objetivas e reproduzíveis (testes,
comandos, consultas).

## Handoff

O que o próximo passo recebe: arquivos gerados, nomes definidos, decisões tomadas.
Por fim, a mensagem de commit sugerida, no padrão de commits das regras gerais,
citando TAR_NNN.XX.

## Conclusão

Enquanto o passo não termina, "Ainda não concluído.". Depois: o que foi decidido,
executado ou encontrado no código, com os desvios do plano e o motivo.
```

Seções sem conteúdo recebem "Nenhum." ou "Não se aplica.", sem ser omitidas.

## Regras da tarefa

O `.meta/regras.md` dentro da pasta da tarefa.

```markdown
# Regras: TAR_NNN, título da tarefa

- **Identificador:** `TAR_NNN.XX`, os passos da tarefa
- **Modelo:** o das tarefas, em [../../.meta/modelo.md](../../.meta/modelo.md)
- **Nome do arquivo:** `TAR_NNN.XX-titulo-curto.md` para os passos; os arquivos de apoio, como definido abaixo
- **Descrição no índice:** dos passos, o objetivo e o estado; dos arquivos de apoio, o que contêm e que passo os usa
- **Ao encerrar:** o da tarefa, nas regras do tópico
- **Subtópicos:** nenhum

## Base

As [regras do tópico de tarefas](../../.meta/regras.md) são a fonte original e a
base desta tarefa: tudo o que não for especificado aqui segue aquelas regras. As
regras abaixo as estendem ou sobrescrevem só no ponto indicado.

## Extensões

Regras próprias desta tarefa que se somam às do tópico, ou "Nenhuma.".

## Sobrescritas

Para cada regra do tópico substituída nesta tarefa: a regra, a substituição e o
motivo. O resto daquela regra continua valendo. Sem sobrescritas, "Nenhuma.".
```
