---
name: sync
description: Keeps the repo-docs documentation consistent when creating, changing, closing, moving or renaming documents in docs/ (next identifier, .meta/index.md index, topic README, history of the day) and reviews the TODO/FIXME of the changed files against the issues. Use whenever recording a decision, issue, improvement, requirement, task or other document in a repository whose docs/ folder has .meta/rules.md, when planning or executing the steps of a task, or when resolving an issue and revoking a decision.
argument-hint: "[operation and document] [--all-todos]"
---

# repo-docs: sync

Applies the documentation rules to a change in `docs/`, whether requested by the
user (`$ARGUMENTS`) or part of another task.

Plugin resources:

- Next identifier and verification: `${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh`
  and `audit.ps1`.

## 1. Rules

1. Read `docs/.meta/rules.md` (general rules) and the `.meta/rules.md` of the
   affected topic, as well as `.meta/template.md`, when there is one. The topic
   rules prevail over the general ones.
2. The `.meta/` folder may be ignored by Glob/Grep searches: read the files by their
   explicit path.
3. If it is not clear which topic the subject fits in, use the What to record
   section of each topic's rules and, if the doubt persists, ask.

## 2. Operations

### Create document

1. With an identifier, get the next free number with the script, from the
   repository root:
   - `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" --next-id PRE docs`
   - `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" -NextId PRE docs`
2. Name the file according to the **File name** field and fill in the template; the
   title starts with the identifier (`# PRE_NNN: ...`).
3. Link the related documents in both directions when the rules require it (for
   example, **Details**/**Detailed by** in requirements).

### Create folder document

When the **File name** field of the topic defines one folder per document (for
example, tasks), according to the Folder documents section of the general rules:

1. Follow the Before planning section (or equivalent) of the topic rules before
   writing any file.
2. Get the identifier as in Create document and create the folder
   `PRE_NNN-short-title/` with:
   - `README.md` from the topic template, with the title `# PRE_NNN: ...`;
   - `.meta/rules.md` from the folder rules template, with the Identifier
     `` `PRE_NNN.XX` ``;
   - `.meta/index.md` with the inner files and the supporting files.
3. Number the inner files with the script, using the folder identifier:
   - `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" --next-id PRE_NNN docs`
   - `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" -NextId PRE_NNN docs`
4. The folder goes into the topic index as a subtopic
   (`- [PRE_NNN-title/](../PRE_NNN-title/): Description.`).

### Change document

Edit the content to reflect the current state (without adding versions) and update
**Updated**. If the index description is no longer correct, rewrite it.

In a folder document, a change to an inner file (for example, the state of a step)
also updates the folder's `README.md`, as the topic rules require (Steps section and
task state), and the folder description in the topic index, if it is no longer
correct.

### Close document

Follow the **On closing** field of the topic:

- **Closed section**: remove the file and move the line to `## Closed` at the end of
  the index (creating the section if needed), with the name between backticks
  without a link and the description starting with the outcome and the date, in
  numeric order.
- **Move to subtopic** (e.g. resolved issue, completed task): fill in what the rules
  require (Resolution section, Conclusion sections), move the file or the folder,
  fix its relative links and the links of other documents to it, and move the line
  to the subtopic index with the description rewritten. When moving a folder, the
  depth changes: fix the links of all its files that point outside the folder
  (including those in `.meta/`).
- **Remove**: remove the file and the index line.

In all cases, move the content that still applies to where it will live from then
on and fix the links of other documents to the removed file.

### Move or rename

Move the file, update the source and destination indexes and fix the links that
point to it, including in the history.

## 3. Index, README and history

1. Update the topic's `.meta/index.md`: one item per document, in the format and
   length of the general rules, in alphabetical order, and the **Updated** date.
2. Review the topic's `README.md` when the documents it highlights change; it does
   not list all documents.
3. If `docs/history/` exists, record creations, content changes and removals in the
   file of the day (`YYYY-MM-DD.md`), according to the history rules, creating the
   file and the item in the history index if needed. Index updates and formatting
   fixes are not recorded.
4. Dates and times come from the system clock, never estimated: `date +%F` and
   `date +%H:%M` (bash) or `Get-Date -Format yyyy-MM-dd` and
   `Get-Date -Format HH:mm` (PowerShell).

## 4. TODO and FIXME review

If the `issues/` topic exists, review the pending items noted in the code. There are
two scopes:

- **Changed files** (default, on every run): the files from
  `git diff --name-only HEAD` and `git ls-files --others --exclude-standard`. Outside
  a git repository, this scope is skipped.
- **Whole repository**: when `$ARGUMENTS` contains `--all-todos` or the user asks
  for a review of all the code. It can be run on its own, without another document
  operation.

Steps:

1. List the occurrences with the inventory script, from the repository root. In the
   changed files scope, pass the files; in the whole repository scope, pass none:
   - `bash "${CLAUDE_PLUGIN_ROOT}/skills/migrate/scripts/inventory.sh" --todos [files...]`
   - `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/migrate/scripts/inventory.ps1" -Todos [files...]`
2. Compare with the Items section of the open issues (`docs/issues/*.md`), by file
   and by comment text (the line may have changed):
   - occurrence that no issue cites: propose recording it, as an item of an existing
     issue on the same subject or in a new issue, in the format
     `` - `path:line`: `text` ``, where `text` is the line exactly as the script
     prints it (without fixing spelling or accents), optionally followed by
     "; effect: ..." with the effect on the system;
   - issue item whose comment no longer exists in the cited file: point it out and
     propose updating the issue (or resolving it, if no item remains). In the
     changed files scope, check only the items that cite those files; in the whole
     repository scope, all items of all open issues;
   - item whose line changed: propose updating the line number.
3. In the whole repository, first present a summary (unrecorded occurrences per
   folder, items without a comment, outdated lines) and propose the records grouped
   by subject, for approval as a block or per group. Trivial or obsolete occurrences
   may be left out, with approval.
4. Record only with approval. The code is not changed: the comment stays and the
   issue indicates where it is.

## 5. Verification

When finished, run the mechanical verification and fix whatever is reported:

- `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" docs`
- `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" docs`

Report the files created, changed and removed and the identifier used. Do not commit
without being asked; when the user asks, the message follows the "Commit messages"
item of the Conventions of the general rules and cites the identifier. If the item
does not exist, ask the user for the pattern, as in `init`, and propose adding it.
