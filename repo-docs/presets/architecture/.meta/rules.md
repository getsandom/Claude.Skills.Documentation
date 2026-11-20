# Rules: architecture

- **Identifier:** none
- **Template:** [template.md](template.md)
- **File name:** `component-name.md` (e.g. `delivery-dispatcher.md`); `overview.md` for the system as a whole
- **Index description:** the component's responsibility and, when applicable, its state
- **On closing:** remove the file when the component ceases to exist and record it in the history; there is no Closed section
- **Subtopics:** none

## What to record

How a part of the system is built or will be built: responsibilities, flows,
contracts and rules. The reason for the choices lives in the decisions, linked
from the document.

## Lifecycle

- One component or flow per file. `overview.md` describes the system as a whole
  and points to the others.
- Update the document whenever the component changes.
- When the state is Partial or Planned, the section "Differences between planned and
  implemented" is mandatory.
