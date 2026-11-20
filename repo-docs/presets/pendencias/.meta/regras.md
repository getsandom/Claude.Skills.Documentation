# Regras: pendências

- **Identificador:** `PEN_NNN`
- **Modelo:** [modelo.md](modelo.md)
- **Nome do arquivo:** `PEN_NNN-titulo-curto.md` (ex.: `PEN_001-criacao-de-inquilinos.md`)
- **Descrição no índice:** a pergunta ou o problema, o tipo e o status
- **Ao encerrar:** preencher a seção Resolução e mover o arquivo para `resolvidas/`; não há seção Encerrados
- **Subtópicos:** `resolvidas/`, as pendências já resolvidas, que compartilham a numeração `PEN_NNN`

## O que registrar

Uma pendência é algo que precisa ser resolvido e ainda não foi: uma decisão em
aberto, um defeito conhecido ou um débito técnico. Depois de resolvida, ela é
mantida em `resolvidas/`, para que as opções consideradas e o que foi feito
continuem consultáveis.

## Ciclo de vida

- O próximo identificador considera também as pendências em `resolvidas/`.
- Edite a pendência conforme a discussão avança (novas opções, critérios, itens),
  atualizando o status (Aberta, Em discussão).
- Nenhuma opção levantada sai da lista sem registro do motivo.
- Quando for resolvida:
  1. registre o resultado onde ele passa a valer (uma decisão, um documento de
     arquitetura, o próprio código);
  2. mude o status para Resolvida, atualize a data e preencha a seção Resolução; o
     restante do conteúdo é mantido como estava;
  3. mova o arquivo para `resolvidas/`, corrigindo os links relativos dele e os
     links de outros documentos para ele;
  4. mova a linha dela deste índice para o índice de `resolvidas/`, com a descrição
     reescrita conforme as regras daquele subtópico;
  5. registre no histórico.

## Seção Resolução

Seção final de toda pendência. Enquanto ela está aberta ou em discussão, contém
apenas "Ainda não resolvida.". Ao ser resolvida, passa a ter:

```markdown
## Resolução

- **Resolvida em:** DD/MM/AAAA
- **Resultado:** onde o resultado passou a valer, com link (decisão, arquitetura,
  código)
- **Referência:** commit e entrada do histórico

Ações tomadas: a opção adotada e o motivo, o que foi alterado e para onde foram os
itens que não foram resolvidos aqui.
```
