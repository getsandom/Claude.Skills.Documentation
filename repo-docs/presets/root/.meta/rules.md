# Rules: documentation

- **Identifier:** none
- **Template:** none
- **File name:** not applicable; the root contains only the topics and, when there is one, the glossary (`glossary.md`)
- **Index description:** what the topic gathers
- **On closing:** not applicable
- **Subtopics:** the documentation topics, listed in the [index](index.md)

These rules apply to all topics. A topic's rules complement the general ones and,
in case of conflict, prevail within that topic.

## Structure of a topic

A topic is a folder that gathers documents of the same type. The root `docs/` is
also a topic, whose subtopics are the documentation topics.

```
topic/
├─ README.md          introduction: why the topic exists and the most relevant documents
├─ <documents>        topic content
├─ <subtopic>/        subtopic, with the same structure
└─ .meta/
   ├─ index.md        list of all documents and subtopics, one line per item
   ├─ rules.md        how the topic works: identifier, lifecycle, index
   └─ template.md     (optional) structure of the topic's documents
```

- Every subfolder of a topic, except `.meta/`, is a subtopic and has its own
  `README.md` and `.meta/`.
- The `README.md` is not an index: it introduces the topic and points to the most
  relevant documents. The full list is in `.meta/index.md`.
- The `.meta/rules.md` starts with a block of fixed fields, in the order below,
  followed by prose sections (What to record, Lifecycle and whatever else the topic
  requires):
  - **Identifier:** prefix in the format `PRE_NNN`, or none;
  - **Template:** link to `template.md`, or none;
  - **File name:** naming pattern of the documents;
  - **Index description:** what the description of each item must say;
  - **On closing:** what happens when a document no longer applies;
  - **Subtopics:** the subtopics and what each one gathers, or none.
- The `.meta/` folder is hidden from some search tools; read its files by their
  explicit path.
- At the root, `.meta/migration.md` exists when the documentation was migrated from
  another format: during the migration, it holds the plan; afterwards, the record of
  what was done, with the previous structure and the mapping between old and new
  paths and identifiers. Old paths stay between backticks, without a link. The file
  is not removed nor listed in the index.

## Indexes

The `.meta/index.md` of each topic lists, one line per item, the content documents
and the immediate subtopics, so that a document can be found without opening each
file.

### What to list

- The content documents and the immediate subtopics of the topic.
- The `README.md` and the files in `.meta/` are not listed.
- Alphabetical order of the name (byte order), which in topics with an identifier
  matches the numeric order and, in the history, the chronological order.
- Removed documents with an identifier remain listed in the Closed section (see
  [Closed documents](#closed-documents)), unless the topic rules set another
  destination.

### Format of each item

```markdown
- [file-name.md](../file-name.md): Description.
```

- The link text is the exact file name, with extension; for subtopics, the name
  followed by a slash (`subtopic/`). The target is relative to the `.meta/` folder,
  so it starts with `../`.
- The description says what the document is about and the main point of its
  content, without merely repeating the title, according to the **Index
  description** field of the topic rules.
- Length: preferably between 200 and 300 characters, never more than 500.
- One or two sentences, without lists or line breaks inside the description.

### Closed documents

When a document with an identifier is removed, its line leaves the current list and
moves to the `## Closed` section, at the end of the index. This way the identifier
can still be found after the file ceases to exist, for example when it is cited in
a commit or in the history.

```markdown
- `PRE_NNN-title.md`: Outcome on YYYY-MM-DD. Description.
```

- The file name stays between backticks, without a link, because the file no longer
  exists.
- The description starts with the outcome, according to the topic rules, and the
  date; then, a reminder of the content and where it went, with a link to the
  destination when there is one.
- Same length limits as the other items, in numeric order.
- The section only exists when there is at least one item, and its items are not
  removed.

### File structure

```markdown
# Index: topic name

- **Updated:** YYYY-MM-DD

- [PRE_001-title.md](../PRE_001-title.md): Description.
- [subtopic/](../subtopic/): Description.

## Closed

- `PRE_002-title.md`: Outcome on YYYY-MM-DD. Description.
```

### Maintenance

The index is updated together with the topic: when creating, removing, moving or
renaming a document, or when a content change makes the description incorrect; the
**Updated** date follows each change. Updating the index does not need a history
entry. The topic's `README.md` is reviewed when the documents it highlights change.

## Identifiers

Topics with an identifier number their documents with their own prefix, an
underscore and three digits (`PRE_NNN`). A subtopic only uses the parent topic's
prefix when its rules say it shares the numbering.

| Prefix | Topic |
|---|---|

- The identifier starts the file name (`PRE_004-short-title.md`) and the title
  (`# PRE_004: ...`).
- The next identifier is the highest number already used with the prefix plus one,
  considering the files, the subtopics that share the prefix and the Closed
  sections. Numbers are not reused.
- Links to these documents carry the identifier in the text, followed by a summary
  (for example, `[PRE_004: title](path/PRE_004-title.md)`).
- Commits and pull requests that deal with a topic cite the identifier (for
  example, "resolves PRE_010").

### Folder documents

When the **File name** field of a topic defines one folder per document, the
document is a subtopic:

- The identifier starts the folder name (`PRE_004-short-title/`), which has its own
  `README.md`, with the title starting with the identifier (`# PRE_004: ...`), and
  `.meta/`.
- The numbered inner files use a sub-identifier, the folder identifier followed by
  a dot and two digits, starting at `01` (`PRE_004.01`). The **Identifier** field
  of the folder rules declares it as `` `PRE_NNN.XX` ``; the file name starts with
  it (`PRE_004.01-short-title.md`) and so does the title (`# PRE_004.01: ...`).
- The other files in the folder are supporting files and do not start with the
  identifier.
- The next sub-identifier is the highest `XX` used in the folder plus one.
- Commits and pull requests that deal with an inner file cite the sub-identifier
  (for example, "PRE_004.02").

## How to document

1. Choose the topic by the type of subject, according to the What to record section
   of each topic's rules.
2. Follow the topic's `template.md`, when there is one.
3. Give the document the next free identifier, when the topic has an identifier.
4. Keep the document current: edit it when something changes, instead of adding
   versions. When it no longer applies, follow the **On closing** field of the topic
   rules and move the relevant content to where it will live from then on.
5. Update the topic's `.meta/index.md` and, if needed, the `README.md`.
6. Record the relevant decisions and actions in the history (see [History](#history)).

## History

When the `history/` topic exists, creations, content changes and removals of
documents are recorded in the file of the day, according to that topic's rules.
Typo and formatting fixes and index updates do not need to be recorded.

## Conventions

- Dates in the format `YYYY-MM-DD` and times in the format `HH:MM` (00:00 to 23:59).
- Files and folders in kebab-case, without accents, preceded by the identifier when
  there is one.
- References between documents by relative link.
- Domain terms as in the glossary, when there is one; classes and methods by their
  name in the code, between backticks.
- Formal tone.
- Commit messages: {{COMMITS}}.

<!-- repo-docs:optional code-documentation -->
## Documentation in the code

The documentation written in the code itself (comments and API documentation) is
self-contained and does not replace this folder:

- It explains how the code works or how to use it: behavior, parameters, return
  values, exceptions and usage constraints.
- It references only elements of the code itself (types, members, parameters).
- It does not reference documents in this folder (identifiers, paths or links) nor
  record the reason for decisions. The motivation lives in the corresponding
  decision, architecture document or issue.
<!-- /repo-docs:optional code-documentation -->
