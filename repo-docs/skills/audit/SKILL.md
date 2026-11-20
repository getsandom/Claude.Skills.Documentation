---
name: audit
description: Verifica, sem alterar arquivos, a consistência da documentação repo-docs do repositório atual (estrutura dos tópicos, índices, identificadores, links e conteúdo) e relata os problemas encontrados.
disable-model-invocation: true
argument-hint: "[pasta-docs]"
---

# repo-docs: audit

Relata problemas da documentação. Não altera nenhum arquivo; correções ficam para
`/repo-docs:sync`, com aprovação do usuário.

A pasta verificada é `$ARGUMENTS`, se informada; senão, `docs` na raiz do
repositório.

## 1. Verificação mecânica

Execute o script da plataforma a partir da raiz do repositório:

- Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" docs`
- Linux/macOS (ou Git Bash): `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" docs`

Os dois scripts produzem a mesma saída. Eles verificam:

- tópico (toda pasta sob `docs/` que não comece por ponto) sem `README.md`,
  `.meta/index.md` ou `.meta/regras.md`;
- índice que lista item inexistente, que não lista um documento ou subtópico, com
  item repetido, com link de item diferente de `../<nome>` ou fora da ordem
  alfabética (aviso);
- nos tópicos com identificador `PRE_NNN`, nome fora do padrão `PRE_NNN-titulo.md`
  e título que não começa por `# PRE_NNN:`; pastas que começam pelo prefixo
  (documentos em pasta) fora do padrão `PRE_NNN-titulo/` ou com `README.md` cujo
  título não começa por `# PRE_NNN:`;
- nos documentos em pasta (identificador `PRE_NNN.XX`), pasta fora do padrão
  `PRE_NNN-titulo/`, arquivo que começa pelo prefixo fora do padrão
  `PRE_NNN.XX-titulo.md` (com o `NNN` da pasta) e título que não começa por
  `# PRE_NNN.XX:`; os demais arquivos são de apoio e não são verificados;
- identificador ou sub-identificador usado em mais de um arquivo ou pasta, ou
  listado em Encerrados e usado de novo;
- links relativos quebrados, fora de blocos e trechos de código.

Código de saída: 0 sem erros, 1 com erros, 2 se a pasta não existir.

## 2. Verificação de conteúdo

Leia `docs/.meta/regras.md` e o `.meta/regras.md` de cada tópico (pelo caminho; a
pasta `.meta/` pode ser ignorada por Glob/Grep) e verifique, por amostragem quando a
documentação for grande e informando o que foi amostrado:

1. Campos fixos de cada `regras.md` presentes e na ordem das regras gerais.
2. Documentos que seguem o `modelo.md` do tópico: campos do cabeçalho e seções.
3. Descrições do índice: refletem o documento atual (status, estado, desfecho) e
   respeitam o tamanho das regras gerais.
4. Tabela de prefixos de `docs/.meta/regras.md` coerente com o campo
   **Identificador** dos tópicos.
5. Rastreabilidade exigida pelas regras (por exemplo, **Detalha** e **Detalhado
   por** recíprocos nos requisitos).
6. Encerramentos coerentes: pendências resolvidas com a seção Resolução preenchida;
   tarefas concluídas com o estado Concluída e as seções Conclusão preenchidas;
   itens de Encerrados com desfecho e data.
7. Documentos em pasta: `README.md` coerente com os arquivos internos (nas tarefas,
   a seção Passos com o estado de cada passo e o estado da tarefa) e
   `.meta/regras.md` com o link para as regras do tópico válido.
8. Histórico: arquivos com nome `AAAA-MM-DD.md` e entradas no formato do modelo.
9. Convenções das regras gerais com o item "Mensagens de commit".
10. `CLAUDE.md` da raiz do repositório com a seção sobre a documentação.

## 3. Relatório

Apresente primeiro a saída do script, sem alterações, e depois os achados de
conteúdo, cada um com o arquivo, o problema e a regra violada. Termine com a
contagem de erros e avisos e pergunte se o usuário quer corrigi-los com
`/repo-docs:sync`.
