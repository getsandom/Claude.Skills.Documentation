# Rules: tasks

- **Identifier:** `TSK_NNN` (shares the numbering with `completed/`)
- **Template:** [template.md](template.md)
- **File name:** one folder per task, `TSK_NNN-short-title/` (e.g. `TSK_001-citations-in-code/`), and inside it one file per step, `TSK_NNN.XX-short-title.md` (e.g. `TSK_001.01-decision-inventory.md`)
- **Index description:** the goal of the task and its state, with the current step or the blocker
- **On closing:** fill in the Conclusion of the steps and of the task README and move the folder to `completed/`, fixing its relative links and those of other documents to it
- **Subtopics:** one folder per task in progress and `completed/`, the completed tasks

## What to record

A task records the plan and the execution of an extensive and contiguous piece of
work, in several steps, planned to be executed by AI agents almost in sequence and
that must be able to be interrupted and resumed. It does not replace the other
topics:

- the problem that motivates the task lives in an issue, with a link to the task;
- the choices made along the way live in the decisions or in the document where the
  result takes effect;
- the task keeps the how: the steps, the limits, what each step hands over to the
  next and what was found.

### Issue or task

- An issue is an open item that at some point will need to be worked on, be it a
  decision or an implementation in the code. It is objective and covers only what
  is essential for the work at hand, whose execution can usually be inferred from
  the scope itself.
- A task is an extensive and contiguous execution plan for AI agents, with the
  steps planned beforehand and executed almost in sequence.
- A small piece of work, of one or two steps, is an issue, not a task.
- A large issue does not become a task because it is large: it is split into
  several distinct issues.
- An issue only becomes a task when the user explicitly asks for it and the
  execution steps are planned.

## Before planning

1. Check the size of the scope. If it foresees only one or two steps, ask the user
   whether they really want to create the task, proposing to record the work in an
   issue instead; the task is only created with the user's confirmation.
2. Resolve the ambiguities by interviewing the user, one question at a time, before
   writing the steps.

## Task structure

```
TSK_NNN-short-title/
├─ README.md                     central document: scope, proposal, steps and conclusion
├─ TSK_NNN.01-short-title.md     first step
├─ TSK_NNN.02-short-title.md     second step
├─ <supporting files>            inventories, lists and results used by the steps
└─ .meta/
   ├─ index.md                   the steps and the supporting files
   └─ rules.md                   points to these rules as the base and defines extensions and overrides
```

- The task is a folder document, according to the general rules: the `README.md`
  starts with `# TSK_NNN:` and each step with `# TSK_NNN.XX:`.
- The `README.md` follows the task README template and each step follows the step
  template, in [template.md](template.md); an override in the task rules can change
  them.
- `XX` has two digits, starts at `01` in each task and gives the execution order
  (`01`, `02`, ..., `10`, `11`).
- The supporting files do not start with the identifier; their naming convention is
  in the task rules.
- The task's `.meta/rules.md` follows the task rules template, in
  [template.md](template.md):
  - it points to these rules as the original source and the base of the task:
    everything the task rules do not specify follows these rules;
  - the task's own rules may extend these rules or override one point of them; each
    override names the rule of this topic it replaces and says why, and the rest of
    that rule still applies;
  - examples of own rules: the order of the batches, what must not be changed, the
    naming convention of the supporting files.
- The task's `.meta/index.md` lists the steps and the supporting files, in the
  format of the general rules.

## Task lifecycle

- **State:** `Planned`, `In progress`, `Blocked` or `Completed`, in the header of
  the task README and in its description in the index.
- When all steps are completed, the Conclusion of the README is filled in and the
  folder goes to `completed/`, with its line moved to the index of that subtopic.

## Step lifecycle

- **State:** `Pending`, `In progress`, `Blocked` or `Completed`, in the header of
  the step.
- Before starting a step, check its Blockers. If any is missing, the step becomes
  `Blocked`, what is missing is recorded and the execution stops.
- When finished, the step becomes `Completed`, with the Conclusion section filled
  in: what was decided, executed or found in the code.
- The step never leaves the task folder, in any state.
- Every state change of a step updates the Steps section of the task README and, if
  needed, the state of the task.
- Commits and pull requests of a step follow the commit pattern of the general rules
  and cite its identifier (for example, "TSK_001.02").
