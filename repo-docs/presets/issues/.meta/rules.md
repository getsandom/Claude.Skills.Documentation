# Rules: issues

- **Identifier:** `ISS_NNN`
- **Template:** [template.md](template.md)
- **File name:** `ISS_NNN-short-title.md` (e.g. `ISS_001-tenant-creation.md`)
- **Index description:** the question or the problem, the type and the status
- **On closing:** fill in the Resolution section and move the file to `resolved/`; there is no Closed section
- **Subtopics:** `resolved/`, the issues already resolved, which share the `ISS_NNN` numbering

## What to record

An issue is something that needs to be resolved and has not been yet: an open
decision, a known defect or a technical debt. Once resolved, it is kept in
`resolved/`, so that the options considered and what was done remain available
for reference.

## Lifecycle

- The next identifier also takes into account the issues in `resolved/`.
- Edit the issue as the discussion progresses (new options, criteria, items),
  updating the status (Open, Under discussion).
- No option raised leaves the list without a record of the reason.
- When it is resolved:
  1. record the result where it takes effect (a decision, an architecture
     document, the code itself);
  2. change the status to Resolved, update the date and fill in the Resolution
     section; the rest of the content is kept as it was;
  3. move the file to `resolved/`, fixing its relative links and the links of other
     documents to it;
  4. move its line from this index to the index of `resolved/`, with the description
     rewritten according to the rules of that subtopic;
  5. record it in the history.

## Resolution section

Final section of every issue. While the issue is open or under discussion, it
contains only "Not resolved yet.". Once resolved, it contains:

```markdown
## Resolution

- **Resolved on:** YYYY-MM-DD
- **Result:** where the result took effect, with a link (decision, architecture,
  code)
- **Reference:** commit and history entry

Actions taken: the option adopted and the reason, what was changed and where the
items that were not resolved here went.
```
