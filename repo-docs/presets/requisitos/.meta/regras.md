# Regras: requisitos

- **Identificador:** nenhum (cada subtópico tem o seu)
- **Modelo:** nenhum (cada subtópico tem o seu)
- **Nome do arquivo:** não se aplica; os documentos ficam nos subtópicos
- **Descrição no índice:** o que o subtópico reúne
- **Ao encerrar:** não se aplica
- **Subtópicos:** `usuario/` (requisitos de usuário, `RQU_NNN`) e `sistema/` (requisitos de sistema, `RQS_NNN`)

## O que registrar

Um requisito descreve, em alto nível, uma necessidade que o sistema deve atender. Ele
diz **o quê**, não **como**.

- **De usuário** (`usuario/`): necessidades de quem usa o sistema, em linguagem de
  negócio. Usuários incluem as pessoas atendidas, os gestores e, quando o sistema é
  consumido por outros sistemas, os desenvolvedores que o integram.
- **De sistema** (`sistema/`): descrições mais precisas do que o sistema deve fazer
  ou respeitar para atender os requisitos de usuário.

## Rastreabilidade

- Todo requisito de sistema detalha ao menos um requisito de usuário.
- Mantenha a rastreabilidade nos dois sentidos: ao criar um requisito de sistema,
  liste-o em **Detalha** e acrescente-o em **Detalhado por** no requisito de usuário
  correspondente.

## Estado

- **Atendido:** todos os critérios de aceitação são verificados por teste
  automatizado ou por verificação registrada.
- **Parcial:** parte dos critérios é atendida e verificada.
- **Não atendido:** nenhum critério é atendido.
