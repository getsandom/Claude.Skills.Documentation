# Claude.Skills.Documentation

Collection of Claude Code plugins for project documentation by Claude, distributed
as a marketplace (`claude-documentation`).

## Plugins

| Plugin | Documentation source | Commands |
|---|---|---|
| [repo-docs](repo-docs/) | `docs/` folder versioned in the repository itself | `init`, `add-topic`, `sync`, `audit`, `migrate` |

## Installation

From the repository on GitHub:

```bash
claude plugin marketplace add getsandom/Claude.Skills.Documentation
claude plugin install repo-docs@claude-documentation
```

From a local clone:

```bash
claude plugin marketplace add <clone-path>
claude plugin install repo-docs@claude-documentation
```

Inside a session, the equivalents are `/plugin marketplace add <source>` and
`/plugin install repo-docs@claude-documentation`. To test changes without
installing: `claude --plugin-dir ./repo-docs`.

## Standards

The standards for creating and maintaining plugins and skills in this collection,
and the decisions that support them, are in [GUIDELINES.md](GUIDELINES.md).
