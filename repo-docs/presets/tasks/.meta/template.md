# Task template

Three templates: the task README, the step and the task rules.

## Task README

```markdown
# TSK_NNN: Task title

- **State:** Planned | In progress | Blocked | Completed
- **Origin:** link to the issue, or the user's request with its date
- **Updated:** YYYY-MM-DD

## Scope

What the task covers and what is left out, in summary.

## Proposal

How the task addresses the scope: the approach and the decisions it follows, with
links.

## Steps

- [TSK_NNN.01: title](TSK_NNN.01-short-title.md): Pending | In progress | Blocked | Completed
- [TSK_NNN.02: title](TSK_NNN.02-short-title.md): Pending

## Conclusion

While the task is not finished, "Not completed yet.". Afterwards: the overall
result, where it took effect (decisions, documents, code) and what was left for
another issue or task.
```

## Step

```markdown
# TSK_NNN.XX: Step title

- **State:** Pending | In progress | Blocked | Completed
- **Depends on:** TSK_NNN.XX, or none
- **Next:** TSK_NNN.XX, or none
- **Updated:** YYYY-MM-DD

## Context

What to read before starting: documents, code files and relevant sections, with
links, and what each one brings to the step.

## Blockers

What must be resolved before starting: user decisions, previous steps, access,
data. Check each item before starting; if any is missing, record here what is
missing, change the state to Blocked and stop. Without impediments, "None.".

## Action

What to do, in numbered items (1, 2, ...), with the files, types and rules
involved.

## Limits

What the step must not do: what is left for another step, what must not be
changed, the discarded approaches.

## Success criterion

How to know the step is finished: objective and reproducible checks (tests,
commands, queries).

## Handoff

What the next step receives: generated files, defined names, decisions taken.
Finally, the suggested commit message, following the commit pattern of the general
rules, citing TSK_NNN.XX.

## Conclusion

While the step is not finished, "Not completed yet.". Afterwards: what was decided,
executed or found in the code, with the deviations from the plan and the reason.
```

Sections without content receive "None." or "Not applicable.", without being
omitted.

## Task rules

The `.meta/rules.md` inside the task folder.

```markdown
# Rules: TSK_NNN, task title

- **Identifier:** `TSK_NNN.XX`, the steps of the task
- **Template:** the tasks one, in [../../.meta/template.md](../../.meta/template.md)
- **File name:** `TSK_NNN.XX-short-title.md` for the steps; the supporting files, as defined below
- **Index description:** for the steps, the goal and the state; for the supporting files, what they contain and which step uses them
- **On closing:** the task's, in the topic rules
- **Subtopics:** none

## Base

The [rules of the tasks topic](../../.meta/rules.md) are the original source and the
base of this task: everything not specified here follows those rules. The rules
below extend or override them only at the indicated point.

## Extensions

Rules specific to this task that add to those of the topic, or "None.".

## Overrides

For each topic rule replaced in this task: the rule, the replacement and the
reason. The rest of that rule still applies. Without overrides, "None.".
```
