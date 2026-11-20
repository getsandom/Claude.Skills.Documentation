---
name: init
description: Creates the repo-docs documentation structure (docs/ folder organized in topics with README.md and .meta/) in the current repository, interviewing the user about the desired topics.
disable-model-invocation: true
argument-hint: "[project name]"
---

# repo-docs: init

Creates `docs/` in the current repository from the plugin presets, according to the
user's choices.

Plugin resources:

- Presets: `${CLAUDE_PLUGIN_ROOT}/presets/` (catalog in
  `${CLAUDE_PLUGIN_ROOT}/presets/catalog.md`; read it before starting).
- Verification: `${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh` and `audit.ps1`.

## 1. Preconditions

1. Identify the repository root (`git rev-parse --show-toplevel`; without git, the
   current directory) and confirm with the user if in doubt.
2. If `docs/.meta/rules.md` exists, the structure has already been created: report
   it and suggest `/repo-docs:add-topic` or `/repo-docs:audit`. Stop.
3. If `docs/` exists without `docs/.meta/`, there is documentation in another format:
   report what exists and suggest `/repo-docs:migrate`, which inventories and
   migrates the existing documentation. Stop; never overwrite or move files without
   explicit approval.
4. If there is other documentation in the repository (ADRs, scattered Markdown,
   decision or architecture sections in the `README.md`), mention at the end that
   `/repo-docs:migrate` can bring it into the new structure.

## 2. Interview

Ask one item at a time (with AskUserQuestion, when available), waiting for each
answer:

1. **Project name**: `$ARGUMENTS`, if given; otherwise, suggest the name of the
   repository folder.
2. **Topics**: multiple selection among the catalog presets, all recommended.
   Report the catalog dependencies (for example, `scripts` presupposes `support`).
3. **Optional subtopics**: for each chosen topic with an optional subtopic
   (currently, `architecture/domain/`), ask whether it should be included.
   Mandatory subtopics (`issues/resolved/`, `requirements/user/` and `system/`,
   `tasks/completed/`) are always copied.
4. **Glossary**: include `docs/glossary.md`?
5. **Documentation in the code**: include the self-contained code documentation rule
   in the general rules?
6. **Commit pattern**: the commit message pattern, which goes into the Conventions of
   the general rules. Read the recent messages
   (`git log --no-merges --format=%s -n 50`):
   - with history, describe the predominant pattern with two or three real examples
     and propose it;
   - without history, without an identifiable pattern or without a user preference,
     propose Conventional Commits (`type(scope): summary`);
   - the user may define another pattern.
7. **Own topics**: does the user want to create other topics now? If so, note them
   and run the `/repo-docs:add-topic` flow for each one after step 3.

Then show the resulting tree and ask for confirmation before writing.

## 3. Creation

1. Copy `presets/root/` (including `.meta/`) to `docs/`, without `glossary.md` if it
   was not chosen.
2. Copy each chosen preset to `docs/<preset>/`, recursively, including the `.meta/`
   folders; omit the declined optional subtopics.
3. In all copied files, replace `{{PROJECT}}` with the project name and `{{DATE}}`
   with today's date in `YYYY-MM-DD`. Check that no `{{` remains.
4. In `docs/.meta/rules.md`:
   - fill in the prefix table with one line per topic with an identifier
     (`| \`DEC\` | [decisions](../decisions/) |`), in alphabetical order of the
     prefix; subtopics that share the parent's prefix do not get a line;
   - keep or remove the optional code documentation block according to the answer
     (see catalog);
   - replace `{{COMMITS}}` with the description of the chosen commit pattern, with
     an example (see catalog).
5. In `docs/.meta/index.md`, add one item per chosen topic and, if applicable, for
   the glossary, with the catalog description, in alphabetical order of the name,
   in the format `- [decisions/](../decisions/): Description.`
6. If `architecture/domain/` was included, add its item to
   `docs/architecture/.meta/index.md`; if it was declined, check that no copied file
   references it.
7. If `history` was chosen, create `docs/history/YYYY-MM-DD.md` with the entry for
   the creation of the structure (type Creation, documents `docs/README.md` and the
   topics, reason "Creation of the documentation structure by repo-docs.")
   according to `docs/history/.meta/template.md`, and the corresponding item in the
   history index. Dates and times come from the system clock (`date` in bash,
   `Get-Date` in PowerShell), never estimated.

## 4. CLAUDE.md

Propose the excerpt below for the `CLAUDE.md` at the repository root (creating the
file if it does not exist), show it and write it only with explicit approval. If
there is already a section about documentation, propose merging instead of
duplicating.

```markdown
## Documentation (`docs/`)

The documentation follows the repo-docs structure: each topic is a folder with
`README.md` (introduction), content documents and `.meta/` (`index.md`, `rules.md`
and, when there is one, `template.md`). Before creating or changing documents, read
`docs/README.md`, `docs/.meta/rules.md` and the topic's `.meta/rules.md`; the
`.meta/` folder is hidden from some searches, so read it by its path. Keep the topic
index and the history up to date.
```

## 5. Verification

Run the mechanical verification from the repository root and show the result:

- Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" docs`
- Linux/macOS (or Git Bash): `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" docs`

The expected result is `Summary: 0 error(s), 0 warning(s).`. Fix whatever is
reported before finishing and report the files created. Do not commit without being
asked.
