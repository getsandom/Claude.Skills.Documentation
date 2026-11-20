# Catálogo de presets

Tópicos pré-definidos que `init` e `add-topic` oferecem. Cada pasta deste diretório
tem a estrutura final do tópico (`README.md` e `.meta/`), com os marcadores
`{{PROJETO}}` (nome do projeto) e `{{DATA}}` (data de criação, `DD/MM/AAAA`) a
substituir. Em `raiz/.meta/regras.md` há também `{{COMMITS}}`, o padrão das
mensagens de commit do repositório (ver Raiz).

## Raiz

`raiz/` é copiada para a própria pasta `docs/`. Contém o `README.md` de entrada, o
`.meta/index.md` vazio e o `.meta/regras.md` com as regras transversais, incluindo:

- a tabela de prefixos da seção Identificadores, preenchida com os prefixos dos
  tópicos incluídos;
- o bloco opcional delimitado por `<!-- repo-docs:opcional documentacao-no-codigo -->`
  e `<!-- /repo-docs:opcional documentacao-no-codigo -->`: mantido sem os
  marcadores quando a regra for aceita, removido com os marcadores quando não for;
- o item "Mensagens de commit" da seção Convenções, com `{{COMMITS}}` substituído
  pela descrição do padrão escolhido na entrevista, com um exemplo (por exemplo,
  "Conventional Commits, `tipo(escopo): resumo` (ex.: `docs(decisoes): registra
  DEC_004`)").

`raiz/glossario.md` é opcional e, quando incluído, vai para `docs/glossario.md`.

## Tópicos

| Preset | Prefixo | Subtópicos | Descrição no índice da raiz |
|---|---|---|---|
| `arquitetura` | — | `dominio/` (opcional) | Como cada componente é ou será construído: responsabilidades, fluxos, contratos e regras, com o que ainda diverge do planejado. |
| `decisoes` | `DEC` | — | Escolhas já tomadas sobre comportamento, contratos e estrutura, com o contexto, as alternativas descartadas e as consequências. |
| `historico` | — | — | Registro resumido, um arquivo por dia, das criações, alterações e remoções de documentos, com o motivo de cada uma. |
| `melhorias` | `MEL` | — | Propostas de funcionalidade ou evolução fora do escopo atual, com motivação, impacto e questões em aberto. |
| `pendencias` | `PEN` | `resolvidas/` (obrigatório) | Decisões em aberto, defeitos e débitos técnicos, com as opções em pauta; as resolvidas ficam em `resolvidas/`, com a resolução. |
| `requisitos` | — | `usuario/` (`RQU`) e `sistema/` (`RQS`), obrigatórios | Necessidades que o sistema deve atender: de usuário, em linguagem de negócio, e de sistema, que as detalham, com rastreabilidade entre elas. |
| `scripts` | — | — | Scripts de instalação e operação citados pelos guias de suporte. |
| `suporte` | — | — | Guias para instalar, configurar e operar o sistema, com procedimento, verificação e problemas comuns. |
| `tarefas` | `TAR` | `concluidas/` (obrigatório) | Planos extensos executados em passos por agentes de IA, uma pasta por tarefa com um arquivo por passo (contexto, bloqueios, ação, limites, critério de sucesso, handoff e conclusão); as concluídas ficam em `concluidas/`. |

Descrição do glossário no índice da raiz: "Termos do domínio com sentido específico
no projeto e o nome correspondente no código."

## Dependências entre presets

- `scripts` pressupõe `suporte`, que cita os scripts.
- `arquitetura/dominio/` usa o glossário, quando houver, para nomear os arquivos.
- As regras de `decisoes`, `melhorias` e `pendencias` citam umas às outras e o
  histórico pelo nome do tópico; elas continuam válidas quando algum deles não
  existe, mas vale incluí-los juntos.
- As regras de `tarefas` citam as pendências e as decisões pelo nome; elas
  continuam válidas sem esses tópicos, mas a origem de uma tarefa costuma ser uma
  pendência. As tarefas são documentos em pasta (`TAR_NNN-titulo/`), com passos
  `TAR_NNN.XX`, conforme as regras gerais.
