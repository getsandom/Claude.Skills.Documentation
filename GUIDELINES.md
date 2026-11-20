# Collection guidelines

Standards for creating and maintaining plugins and skills in this repository,
followed by the decisions that support them.

- **Updated:** 2026-11-20

## Repository structure

```
Claude.Skills.Documentation/
├─ .claude-plugin/marketplace.json     collection marketplace
├─ README.md                           introduction and installation
├─ GUIDELINES.md                       this document
└─ <plugin>/                           one plugin per documentation source
   ├─ .claude-plugin/plugin.json
   ├─ README.md                        commands, concepts and limitations of the plugin
   ├─ <shared resources>/              e.g. presets/, used by more than one skill
   └─ skills/<command>/SKILL.md        one skill per command
      └─ scripts/                      skill scripts, when there are any
```

## Plugins

- One plugin per documentation source, at the repository root, named
  `<source>-docs` in kebab-case (`repo-docs`; future cloud sources, such as
  `notion-docs` or `confluence-docs`).
- Every plugin is listed in `.claude-plugin/marketplace.json` with a relative
  `source` (`./<plugin>`); the `name` of the entry is equal to the `name` of
  `plugin.json`.
- Resources used by more than one skill live at the plugin root and are referenced
  through `${CLAUDE_PLUGIN_ROOT}`. Nothing outside the plugin folder is referenced:
  on installation, only the plugin folder is copied.
- `version` in `plugin.json` and in the marketplace entry, in semantic versioning,
  incremented with each published change.

## Skills

- One skill per command, in `skills/<command>/SKILL.md`, invoked as
  `/<plugin>:<command>`. Short command names, in English and kebab-case, equal
  across plugins when the role is the same (`init`, `add-topic`, `sync`, `audit`).
- Minimal frontmatter: `name`, `description` and `argument-hint` when there is an
  argument.
- Skills that create structure or only check (`init`, `add-topic`, `audit`) use
  `disable-model-invocation: true`. Maintenance skills (`sync`) may be triggered by
  the model, and the `description` says when.
- Instructions, descriptions and generated content in English, with a formal tone.
- Every user decision is asked one item at a time; nothing is overwritten, moved or
  removed without approval, and no skill commits without being asked.
- Every skill that changes files ends with the plugin's mechanical verification
  (`audit`), when there is one.

## Scripts

- Mechanical checks live in scripts, not in instructions to the model, so that the
  result is reproducible.
- Every script exists as a pair, `.ps1` (Windows PowerShell 5.1 and PowerShell 7)
  and `.sh` (bash, without GNU extensions), with the same parameters, the same
  output and the same exit codes. Every change to one is made to the other and
  verified by comparing the outputs over the same test trees.
- The `.ps1` files are saved in UTF-8 with BOM, so that Windows PowerShell 5.1 reads
  non-ASCII text correctly; the `.sh` files, in UTF-8 without BOM and with LF line
  endings.
- Scripts are read-only, unless their name and documentation say otherwise.

## Decisions

### Name `repo-docs`

The plugin covers documentation embedded and versioned in the repository. The name
`local-docs` was discarded because it suggests something local to the machine, not
versioned. The `-docs` suffix groups the plugins of the collection by source.

### Marketplace with one plugin per source, at the root

The collection is a marketplace so that installation and updates are done by Claude
Code itself on any machine. Each documentation source is a separate plugin, so that
the commands are `/repo-docs:init` and do not depend on the collection name. The
intermediate `plugins/` folder was dropped, keeping each plugin with its skills close
to the root. The discarded alternatives were loose folders copied to
`~/.claude/skills` and a single plugin for the whole collection.

### Documentation in topics with `.meta/`

The structure of Claude.Herald was generalized: requirements, decisions and the
other folders become **topics** of the same format. Each topic separates the
introduction (`README.md`, displayed by GitHub when opening the folder) from the
metadata (`.meta/index.md`, `.meta/rules.md`, `.meta/template.md`), so that the
rules of each topic are explicit and the skills do not depend on fixed topics. The
root `docs/` is also a topic, with the cross-cutting rules. The Herald topics are
offered as presets.

### Rules in fixed fields and prose

The `.meta/rules.md` starts with bold fields (Identifier, Template, File name,
Index description, On closing, Subtopics), readable on GitHub and read by the
verification script, followed by prose rules. YAML front matter was discarded
because it departs from the style of the documents.

### Commands `init`, `add-topic`, `sync` and `audit`

`init` creates the structure by interview; `add-topic` adds topics later; `sync`
applies the rules to each document change; `audit` only checks. One command per
maintenance operation was discarded in favor of a single `sync`, triggerable by the
model.

### Project `CLAUDE.md`

`init` proposes an excerpt for the project's `CLAUDE.md`, written only with
approval, so that future sessions follow the structure without invoking the plugin.

### Migration by inventory, plan and record

The `migrate` command brings the existing documentation into the structure: `docs/`
in another format, scattered Markdown, sections of `README.md` and `CLAUDE.md` and
TODO/FIXME in the code. The three-phase flow (inventory, approved plan, execution)
allows reviewing before moving and resuming an interrupted migration. The
`docs/.meta/migration.md` holds the plan and, at the end, is rewritten as a
permanent record of the previous structure and of the mapping between paths and
identifiers, cited by a history entry. The documents are moved with `git mv` and
adapted to the template without loss of content. The identifiers are renumbered in
each topic; preserving the old ones was discarded to keep the numbering continuous,
and the mapping stays in the record. References outside `docs/` only change with
approval. A direct interactive flow, without a written plan, was discarded because
it allows neither review nor resumption.

### TODO and FIXME as issue items

TODO and FIXME in the code become issue items, with file, line and text, and the
code is not changed, which respects the optional self-contained code documentation
rule. On every run, `sync` reviews the TODO/FIXME of the changed files: it proposes
recording the new ones and points out items whose comment disappeared. With the
`--all-todos` argument, the same review covers the whole repository and all open
issues; the option stays in `sync` itself, and not in a `sync-all` skill, to keep a
single reconciliation flow.

### Optional glossary at the root

The glossary is a single file, `docs/glossary.md`, and not a topic, because it is
usually small.
