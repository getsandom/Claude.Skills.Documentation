# Rules: domain

- **Identifier:** none
- **Template:** [template.md](template.md)
- **File name:** the business term of the entity, as in the glossary, when there is one (e.g. `delivery.md`)
- **Index description:** what the entity represents and its main rules
- **On closing:** remove the file when the entity ceases to exist and record it in the history; there is no Closed section
- **Subtopics:** none

## What to record

Each domain entity exactly as it exists in the code. Value types and unions that
belong to the entity stay in the same file.

## Lifecycle

- One entity per file.
- The document reflects the code. Planned changes do not go here.
- If the document and the code diverge, fix the document or open an issue to
  review it.
