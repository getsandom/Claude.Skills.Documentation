# repo-docs

Claude Code plugin for documentation embedded and versioned in the repository
itself, in the `docs/` folder, organized in **topics**.

## Topic model

Each topic is a folder:

```
topic/
├─ README.md          introduction: why the topic exists and the most relevant documents
├─ <documents>        content
├─ <subtopic>/        subtopic, with the same structure
└─ .meta/
   ├─ index.md        one line per document and subtopic, for quick lookup
   ├─ rules.md        fixed fields (identifier, template, closing...) and prose rules
   └─ template.md     (optional) structure of the documents
```

The root `docs/` is also a topic; `docs/.meta/rules.md` holds the rules that apply
to all of them (index format, `PRE_NNN` identifiers, history, conventions).

## Commands

| Command | What it does |
|---|---|
| `/repo-docs:init [project]` | Creates `docs/` from the presets, interviewing the user about topics, subtopics, glossary, code documentation rule, commit pattern and the `CLAUDE.md` excerpt. |
| `/repo-docs:add-topic [name]` | Adds a topic or subtopic, from a preset or defined from scratch. |
| `/repo-docs:sync [operation]` | Creates, changes, closes, moves or renames documents applying the rules: next identifier, index, README and history. Reviews the TODO/FIXME of the changed files against the issues; with `--all-todos`, those of the whole repository. It is also triggered automatically when the task involves documents in `docs/`. |
| `/repo-docs:audit [dir]` | Checks the documentation without changing it: mechanical script and content verification. |
| `/repo-docs:migrate [path]` | Locates the existing documentation (`docs/` in another format, scattered Markdown, sections of `README.md`/`CLAUDE.md`, TODO/FIXME) and migrates it through inventory, plan and execution, renumbering the identifiers; the plan and then the record stay in `docs/.meta/migration.md`. |

## Presets

The catalog is in [presets/catalog.md](presets/catalog.md).

| Preset | Identifier | Subtopics |
|---|---|---|
| `requirements` | — | `user/` (`URQ`), `system/` (`SRQ`) |
| `decisions` | `DEC` | — |
| `architecture` | — | `domain/` (optional) |
| `improvements` | `IMP` | — |
| `issues` | `ISS` | `resolved/` |
| `history` | — | — |
| `support` | — | — |
| `scripts` | — | — |
| `tasks` | `TSK` (steps `TSK_NNN.XX`) | `completed/` |

Root options: `glossary.md` and the self-contained code documentation rule. The
general rules record the commit message pattern, chosen in `init`.

`tasks` uses folder documents: each task is a folder `TSK_NNN-title/`, a subtopic
with `README.md`, `.meta/` and one file per step (`TSK_NNN.XX-title.md`), planned
for execution in sequence by AI agents.

## Mechanical verification

`skills/audit/scripts/audit.ps1` and `skills/audit/scripts/audit.sh` produce the
same output and can be used outside Claude Code, including in CI:

```bash
bash repo-docs/skills/audit/scripts/audit.sh docs
bash repo-docs/skills/audit/scripts/audit.sh --next-id DEC docs
bash repo-docs/skills/audit/scripts/audit.sh --next-id TSK_001 docs
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File repo-docs/skills/audit/scripts/audit.ps1 docs
powershell -NoProfile -ExecutionPolicy Bypass -File repo-docs/skills/audit/scripts/audit.ps1 -NextId DEC docs
powershell -NoProfile -ExecutionPolicy Bypass -File repo-docs/skills/audit/scripts/audit.ps1 -NextId TSK_001 docs
```

With a prefix (`DEC`), `--next-id` prints the next identifier; with the identifier
of a folder document (`TSK_001`), the next sub-identifier (`TSK_001.03`).

Exit code: 0 without errors, 1 with errors, 2 on invalid usage.

`skills/migrate/scripts/inventory.ps1` and `inventory.sh` list, with the same
output, text documents outside the structured documentation (`--markdown`),
TODO/FIXME occurrences (`--todos [files...]`) and literal references outside
`docs/` (`--refs PATTERN`).

## Limitations

- `audit` checks the content by reading against the template, by sampling in large
  documentations.
