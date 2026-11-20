# Rules: requirements

- **Identifier:** none (each subtopic has its own)
- **Template:** none (each subtopic has its own)
- **File name:** not applicable; the documents live in the subtopics
- **Index description:** what the subtopic gathers
- **On closing:** not applicable
- **Subtopics:** `user/` (user requirements, `URQ_NNN`) and `system/` (system requirements, `SRQ_NNN`)

## What to record

A requirement describes, at a high level, a need the system must meet. It says
**what**, not **how**.

- **User** (`user/`): needs of those who use the system, in business language.
  Users include the people served, the managers and, when the system is consumed
  by other systems, the developers who integrate it.
- **System** (`system/`): more precise descriptions of what the system must do or
  comply with to meet the user requirements.

## Traceability

- Every system requirement details at least one user requirement.
- Keep traceability in both directions: when creating a system requirement, list
  the user requirements in **Details** and add it to **Detailed by** in the
  corresponding user requirement.

## State

- **Met:** all acceptance criteria are verified by an automated test or by a
  recorded verification.
- **Partial:** part of the criteria is met and verified.
- **Not met:** no criterion is met.
