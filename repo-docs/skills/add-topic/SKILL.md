---
name: add-topic
description: Adds, in a guided way, a topic or subtopic to the repo-docs documentation of the current repository, from a preset or defined from scratch.
disable-model-invocation: true
argument-hint: "[topic-name]"
---

# repo-docs: add-topic

Adds a topic (or subtopic) to a documentation already created by
`/repo-docs:init`.

Plugin resources:

- Presets: `${CLAUDE_PLUGIN_ROOT}/presets/` (catalog in
  `${CLAUDE_PLUGIN_ROOT}/presets/catalog.md`).
- Verification: `${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh` and `audit.ps1`.

## 1. Context

1. Confirm that `docs/.meta/rules.md` exists; otherwise, suggest `/repo-docs:init`
   and stop.
2. Read `docs/.meta/rules.md` (topic structure, index format, prefix table) and
   `docs/.meta/index.md`. The `.meta/` folder may be ignored by Glob/Grep searches:
   read the files by their path.
3. List the existing topics (folders under `docs/` with `.meta/`).
4. If the Conventions section of `docs/.meta/rules.md` does not have the "Commit
   messages" item (documentation created before that rule), ask the **Commit
   pattern** question from `init` and, with the user's approval, add the item at the
   end of the section, in the catalog format.

## 2. Interview

One item at a time, waiting for each answer. The suggested name is `$ARGUMENTS`, if
given.

1. **Origin**: a catalog preset not yet used, or a new topic.
2. **Parent**: the root `docs/` or an existing topic (to create a subtopic).
3. For a preset: the optional subtopics, as in `init`. Skip to step 3.
4. For a new topic:
   1. **Name** of the folder, in kebab-case without accents, unique in the parent.
   2. **Purpose**: what the topic gathers and why it exists (becomes the
      `README.md` and the description in the parent index).
   3. **What to record** and what belongs in other topics.
   4. **Identifier**: none, its own prefix (2 to 4 uppercase letters, absent from
      the prefix table and from all `.meta/rules.md`) or, for a subtopic, the
      parent's prefix with shared numbering.
   5. **File name**: pattern of the documents (with an identifier, always
      `PRE_NNN-short-title.md`) or, for documents made of several files, a folder
      document (`PRE_NNN-short-title/`, with inner files
      `PRE_NNN.XX-short-title.md`), according to the Folder documents section of
      the general rules. In this case, also gather the template for the folder's
      `README.md`, the one for the inner files and the one for the folder rules
      (Identifier `` `PRE_NNN.XX` ``), as in the `tasks` preset.
   6. **Template**: whether the documents will have a fixed structure; if so,
      gather the header fields and the sections with the user.
   7. **Index description**: what each document's line must say.
   8. **On closing**: Closed section with which outcomes; move to a subtopic (like
      resolved issues); remove without record; or not applicable.
   9. **Lifecycle**: additional rules (states, traceability, reviews).

Show the files that will be created and changed and ask for confirmation before
writing.

## 3. Creation

1. Preset: copy the preset folder into the parent, with `.meta/`, replacing
   `{{PROJECT}}` (project name, taken from the title of `docs/README.md`) and
   `{{DATE}}` (today, `YYYY-MM-DD`).
2. New topic: create, following the format of the presets (use
   `${CLAUDE_PLUGIN_ROOT}/presets/decisions/` as a reference):
   - `README.md`: title, purpose and the "Where to start" section with links to the
     index and the rules;
   - `.meta/index.md`: `# Index: <name>` and `- **Updated:** YYYY-MM-DD`;
   - `.meta/rules.md`: `# Rules: <name>`, the block of fixed fields in the order of
     the general rules (Identifier, Template, File name, Index description, On
     closing, Subtopics), followed by What to record and Lifecycle;
   - `.meta/template.md`, if there is a template: `# <Document> template` and the
     structure in a `markdown` code block; for a folder document, one block per
     template (use `${CLAUDE_PLUGIN_ROOT}/presets/tasks/.meta/template.md` as a
     reference).
3. In the parent:
   - add the topic item to `.meta/index.md`, in alphabetical order, and update the
     date;
   - update the **Subtopics** field of `.meta/rules.md`, if the parent is not the
     root;
   - review the `README.md`, if it highlights the subtopics.
4. If the topic has its own prefix, add the line to the prefix table of
   `docs/.meta/rules.md`, in alphabetical order.
5. If `docs/history/` exists, record the creation in the file of the day, according
   to the history rules.

## 4. Verification

Run the mechanical verification from the repository root:

- Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" docs`
- Linux/macOS (or Git Bash): `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" docs`

Fix whatever is reported and report the files created and changed. Do not commit
without being asked.
