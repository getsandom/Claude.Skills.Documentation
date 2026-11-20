---
name: migrate
description: Locates the existing documentation in the repository (docs/ in another format, scattered Markdown, sections of README.md and CLAUDE.md, TODO/FIXME in the code) and migrates it to the repo-docs structure, through an inventory, a reviewable plan and an execution recorded in docs/.meta/migration.md.
disable-model-invocation: true
argument-hint: "[path to inventory]"
---

# repo-docs: migrate

Migrates the existing documentation to the repo-docs structure in three phases:
inventory, plan and execution. The file `docs/.meta/migration.md` holds the plan
and, afterwards, the record of what was done.

Plugin resources:

- Inventory: `${CLAUDE_PLUGIN_ROOT}/skills/migrate/scripts/inventory.sh` and
  `inventory.ps1` (read-only; usage in the header of each script).
- Next identifier and verification: `${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh`
  and `audit.ps1`.
- Creation of the structure: the instructions in `${CLAUDE_PLUGIN_ROOT}/skills/init/SKILL.md`
  and `${CLAUDE_PLUGIN_ROOT}/skills/add-topic/SKILL.md`.

Commands, from the repository root (Windows: `powershell -NoProfile
-ExecutionPolicy Bypass -File "<script>.ps1"` with `-Markdown`, `-Todos`, `-Refs`,
`-NextId`; Linux/macOS or Git Bash: `bash "<script>.sh"` with `--markdown`,
`--todos`, `--refs`, `--next-id`).

General rules:

- Ask one item at a time and wait for the answer. Nothing outside `docs/` is changed
  without explicit approval; no content is discarded without approval and record.
- Move files with `git mv`, to preserve history; outside a git repository, move
  them normally and record that.
- Dates and times come from the system clock (`date`, `Get-Date`), never estimated.
- If `docs/.meta/migration.md` exists with pending items, the migration was
  interrupted: resume from the first pending item.
- Do not commit without being asked. Suggest commits per phase (structure, each
  topic, record) when the user asks.

## 1. Inventory (read-only)

Over the whole repository or over `$ARGUMENTS`, when given:

1. `inventory --markdown`: text documents outside the structured documentation.
   A `docs/` folder without `.meta/rules.md` is legacy documentation and goes into
   the inventory.
2. `README.md` and `CLAUDE.md` at the root and in subprojects: read them by section
   and mark those that describe decisions, architecture, requirements, operation or
   issues. Introduction, quick installation and agent instruction sections stay.
3. `inventory --todos`: TODO and FIXME in the code.
4. For each document, determine:
   - the destination topic, among the catalog presets
     (`${CLAUDE_PLUGIN_ROOT}/presets/catalog.md`) and the existing topics, or a new
     topic when none fits;
   - the action: **move** (the whole file becomes a document), **split** (a file
     with several subjects becomes several documents), **extract** (section of a
     README or CLAUDE.md), **merge** (the content complements an already existing
     document), **discard** (no useful content; requires approval) or **keep**
     (stays where it is, for example a package `README.md`);
   - the old identifier, when there is one (`DEC_004`, `ADR-0007`, `0007-` in the
     name);
   - the state or outcome, when there is one (superseded decision, resolved issue,
     implemented improvement), to take the document to the right place.
5. Group TODO/FIXME by subject: each group becomes a new issue (type Defect or
   Technical debt) or items of an existing issue. Trivial or obsolete occurrences
   may be ignored, with approval.
6. For each old identifier and each moved document path, run
   `inventory --refs <pattern>` to locate the references outside `docs/`.

Present a summary of the inventory (quantities per source and per topic,
ambiguities) and clarify the ambiguities with the user before continuing.

## 2. Structure

1. If a legacy `docs/` exists, propose `git mv docs docs-legacy`, to free `docs/`
   for the new structure. Write only with approval.
2. If `docs/.meta/rules.md` does not exist, run the `init` flow, suggesting the
   topics the inventory indicated; new topics follow the `add-topic` flow. If the
   structure already exists, create only the missing topics.
3. Identifier prefixes of new topics must not coincide with old ones of a different
   nature, so as not to confuse historical references.

## 3. Plan

Write `docs/.meta/migration.md` in this format (old paths always between backticks,
without a link, because they will cease to exist):

```markdown
# Documentation migration

- **Phase:** Plan | In progress | Completed
- **Started on:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD

## Items

| No. | Source | Action | Destination | Old ID | New ID | State |
|---|---|---|---|---|---|---|
| 1 | `docs-legacy/decisions/DEC_004-x.md` | move | `decisions/` | DEC_004 | DEC_001 | Pending |

## TODO and FIXME

| Group | Occurrences | Destination | State |
|---|---|---|---|

## References outside docs/

| File:line | Reference | Replacement | State |
|---|---|---|---|
```

- The new identifiers are renumbered in each topic, preserving the relative order of
  the old identifiers with the same prefix (`DEC_004` before `DEC_005`). Documents
  from different sources (ADRs, Markdown without an identifier) are placed by
  creation date, when known (date field of the document or first commit,
  `git log --diff-filter=A --format=%as -- <file>`), and at the end, in alphabetical
  order, when not. The update date does not define the order. Get the first one with
  `audit --next-id PRE` and increment in the order of the plan. Documents closed at
  the source also receive a number and go to the Closed section or to the
  destination subtopic, according to the topic rules.
- States: Pending, Done, Ignored (with the reason in the Destination column) and,
  for references, Declined.

Show the plan and ask for approval as a block or item by item; adjust the file
according to the answers.

## 4. Execution

Update **Phase** to "In progress" and, for each completed item, the state in the
table.

1. **Move**: `git mv` to the destination with the name in the topic pattern; adapt
   it to the template without losing content: title with the new identifier, header
   fields (dates from the old content when available, otherwise today's date),
   sections renamed to those of the template. Whatever does not fit in any section
   goes to Notes (or the last section of the template). The old identifier is not
   cited in the document; it stays in `migration.md`.
2. **Split** and **extract**: create the destination documents with the
   corresponding excerpt. At the source (README.md, CLAUDE.md), replace the section
   with a sentence linking to the destination, with approval.
3. **Merge**: add the content to the existing document, in the appropriate section.
4. **TODO/FIXME**: create or update the issues, with one line per occurrence in the
   Items section, in the format `` - `path:line`: `text` ``, where `text` is the
   line exactly as the inventory script prints it (without fixing spelling or
   accents), optionally followed by "; effect: ...". The code is not changed.
5. **Links and identifiers inside `docs/`**: after each topic, update the relative
   links and the mentions of old identifiers in all migrated documents, including
   in the migrated history.
6. **References outside `docs/`**: apply the approved replacements; the declined
   ones stay recorded.
7. Topic indexes and READMEs, according to the general rules.

After each topic, run `audit` and fix whatever is reported.

## 5. Record

When finished (or when interrupted by the user's decision), rewrite
`docs/.meta/migration.md` as the record of what was done, to preserve what the
migration eliminated:

```markdown
# Documentation migration

- **Phase:** Completed
- **Started on:** YYYY-MM-DD
- **Completed on:** YYYY-MM-DD

## Summary

Migrated sources, number of documents per topic and what was left out.

## Previous structure

Summarized tree of the documentation sources before the migration, with the role of
each folder or file and conventions that no longer apply (prefixes, templates,
indexes).

## Mapping

| Source | Old ID | Destination | New ID |
|---|---|---|---|

## Extracted sections

| Source file | Section | Destination |
|---|---|---|

## TODO and FIXME

| Occurrences | Issue |
|---|---|

## References outside docs/

| File | Old reference | Status (updated, declined) |
|---|---|---|

## Items not migrated

| Source | Reason |
|---|---|
```

- Destinations with a relative link (from `docs/.meta/`); sources between
  backticks.
- Remove `docs-legacy/` when it is empty; if anything remains, list it in Items not
  migrated and ask what to do.
- Record in the history of the day an entry (type Change) "Documentation
  migration", with a link to `../.meta/migration.md` and the summary.
- Run the final `audit` and show the result; the expected one is
  `Summary: 0 error(s), 0 warning(s).`
- Check that no source file was lost: the number of inventoried documents equals the
  sum of the migrated, merged, kept and not migrated ones.
