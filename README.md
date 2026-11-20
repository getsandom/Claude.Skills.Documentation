# Claude.Skills.Documentation

Coleção de plugins do Claude Code para documentação de projetos da Claude,
distribuída como marketplace (`claude-documentation`).

## Plugins

| Plugin | Origem da documentação | Comandos |
|---|---|---|
| [repo-docs](repo-docs/) | Pasta `docs/` versionada no próprio repositório | `init`, `add-topic`, `sync`, `audit`, `migrate` |

## Instalação

A partir do repositório no GitHub:

```bash
claude plugin marketplace add claudesolutions/Claude.Skills.Documentation
claude plugin install repo-docs@claude-documentation
```

A partir de um clone local:

```bash
claude plugin marketplace add <caminho-do-clone>
claude plugin install repo-docs@claude-documentation
```

Dentro de uma sessão, os equivalentes são `/plugin marketplace add <origem>` e
`/plugin install repo-docs@claude-documentation`. Para testar alterações sem
instalar: `claude --plugin-dir ./repo-docs`.

## Padrões

Os padrões para criar e manter plugins e skills nesta coleção, e as decisões que os
fundamentam, estão em [GUIDELINES.md](GUIDELINES.md).
