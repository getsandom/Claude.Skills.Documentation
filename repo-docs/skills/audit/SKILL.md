---
name: audit
description: Checks, without changing files, the consistency of the repo-docs documentation of the current repository (topic structure, indexes, identifiers, links and content) and reports the problems found.
disable-model-invocation: true
argument-hint: "[docs-dir]"
---

# repo-docs: audit

Reports problems in the documentation. Does not change any file; fixes are left to
`/repo-docs:sync`, with the user's approval.

The checked folder is `$ARGUMENTS`, if given; otherwise, `docs` at the repository
root.

## 1. Mechanical verification

Run the platform script from the repository root:

- Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.ps1" docs`
- Linux/macOS (or Git Bash): `bash "${CLAUDE_PLUGIN_ROOT}/skills/audit/scripts/audit.sh" docs`

Both scripts produce the same output. They check:

- topic (every folder under `docs/` that does not start with a dot) without
  `README.md`, `.meta/index.md` or `.meta/rules.md`;
- index that lists a nonexistent item, that does not list a document or subtopic,
  with a duplicate item, with an item link other than `../<name>` or out of
  alphabetical order (warning);
- in topics with identifier `PRE_NNN`, name that does not match `PRE_NNN-title.md`
  and title that does not start with `# PRE_NNN:`; folders that start with the
  prefix (folder documents) that do not match `PRE_NNN-title/` or with a
  `README.md` whose title does not start with `# PRE_NNN:`;
- in folder documents (identifier `PRE_NNN.XX`), folder that does not match
  `PRE_NNN-title/`, file starting with the prefix that does not match
  `PRE_NNN.XX-title.md` (with the folder's `NNN`) and title that does not start
  with `# PRE_NNN.XX:`; the other files are supporting files and are not checked;
- identifier or sub-identifier used in more than one file or folder, or listed in
  Closed and used again;
- broken relative links, outside code blocks and code spans.

Exit code: 0 without errors, 1 with errors, 2 if the folder does not exist.

## 2. Content verification

Read `docs/.meta/rules.md` and the `.meta/rules.md` of each topic (by path; the
`.meta/` folder may be ignored by Glob/Grep) and check, by sampling when the
documentation is large and reporting what was sampled:

1. Fixed fields of each `rules.md` present and in the order of the general rules.
2. Documents that follow the topic's `template.md`: header fields and sections.
3. Index descriptions: reflect the current document (status, state, outcome) and
   respect the length of the general rules.
4. Prefix table of `docs/.meta/rules.md` consistent with the **Identifier** field
   of the topics.
5. Traceability required by the rules (for example, reciprocal **Details** and
   **Detailed by** in the requirements).
6. Consistent closings: resolved issues with the Resolution section filled in;
   completed tasks with the state Completed and the Conclusion sections filled in;
   Closed items with outcome and date.
7. Folder documents: `README.md` consistent with the inner files (in tasks, the
   Steps section with the state of each step and the state of the task) and
   `.meta/rules.md` with a valid link to the topic rules.
8. History: files named `YYYY-MM-DD.md` and entries in the template format.
9. Conventions of the general rules with the "Commit messages" item.
10. `CLAUDE.md` at the repository root with the section about the documentation.

## 3. Report

First present the script output, unchanged, and then the content findings, each
with the file, the problem and the violated rule. End with the count of errors and
warnings and ask whether the user wants to fix them with `/repo-docs:sync`.
