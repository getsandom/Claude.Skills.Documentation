# Regras: arquitetura

- **Identificador:** nenhum
- **Modelo:** [modelo.md](modelo.md)
- **Nome do arquivo:** `nome-do-componente.md` (ex.: `despachante-de-entregas.md`); `visao-geral.md` para o sistema como um todo
- **Descrição no índice:** a responsabilidade do componente e, quando houver, o estado
- **Ao encerrar:** remover o arquivo quando o componente deixar de existir e registrar no histórico; não há seção Encerrados
- **Subtópicos:** nenhum

## O que registrar

Como uma parte do sistema é construída ou será construída: responsabilidades,
fluxos, contratos e regras. O motivo das escolhas fica nas decisões, com link a
partir do documento.

## Ciclo de vida

- Um componente ou fluxo por arquivo. `visao-geral.md` descreve o sistema como um
  todo e aponta para os demais.
- Atualize o documento sempre que o componente mudar.
- Quando o estado for Parcial ou Planejado, a seção "Diferenças entre o planejado e o
  implementado" é obrigatória.
