# Preset catalog

Predefined topics offered by `init` and `add-topic`. Each folder in this directory
has the final structure of the topic (`README.md` and `.meta/`), with the
placeholders `{{PROJECT}}` (project name) and `{{DATE}}` (creation date,
`YYYY-MM-DD`) to be replaced. In `root/.meta/rules.md` there is also `{{COMMITS}}`,
the commit message pattern of the repository (see Root).

## Root

`root/` is copied into the `docs/` folder itself. It contains the entry `README.md`,
the empty `.meta/index.md` and the `.meta/rules.md` with the cross-cutting rules,
including:

- the prefix table of the Identifiers section, filled in with the prefixes of the
  included topics;
- the optional block delimited by `<!-- repo-docs:optional code-documentation -->`
  and `<!-- /repo-docs:optional code-documentation -->`: kept without the markers
  when the rule is accepted, removed together with the markers when it is not;
- the "Commit messages" item of the Conventions section, with `{{COMMITS}}` replaced
  by the description of the pattern chosen in the interview, with an example (for
  example, "Conventional Commits, `type(scope): summary` (e.g. `docs(decisions):
  record DEC_004`)").

`root/glossary.md` is optional and, when included, goes to `docs/glossary.md`.

## Topics

| Preset | Prefix | Subtopics | Root index description |
|---|---|---|---|
| `architecture` | — | `domain/` (optional) | How each component is or will be built: responsibilities, flows, contracts and rules, with what still diverges from the plan. |
| `decisions` | `DEC` | — | Choices already made about behavior, contracts and structure, with the context, the discarded alternatives and the consequences. |
| `history` | — | — | Summary record, one file per day, of the creations, changes and removals of documents, with the reason for each one. |
| `improvements` | `IMP` | — | Proposals for features or evolutions outside the current scope, with motivation, impact and open questions. |
| `issues` | `ISS` | `resolved/` (mandatory) | Open decisions, defects and technical debts, with the options on the table; the resolved ones stay in `resolved/`, with their resolution. |
| `requirements` | — | `user/` (`URQ`) and `system/` (`SRQ`), mandatory | Needs the system must meet: user needs, in business language, and system needs, which detail them, with traceability between them. |
| `scripts` | — | — | Installation and operation scripts cited by the support guides. |
| `support` | — | — | Guides to install, configure and operate the system, with procedure, verification and common problems. |
| `tasks` | `TSK` | `completed/` (mandatory) | Extensive plans executed in steps by AI agents, one folder per task with one file per step (context, blockers, action, limits, success criterion, handoff and conclusion); the completed ones stay in `completed/`. |

Glossary description in the root index: "Domain terms with a specific meaning in
the project and the corresponding name in the code."

## Dependencies between presets

- `scripts` presupposes `support`, which cites the scripts.
- `architecture/domain/` uses the glossary, when there is one, to name the files.
- The rules of `decisions`, `improvements` and `issues` cite each other and the
  history by topic name; they remain valid when one of them does not exist, but it
  is worth including them together.
- The rules of `tasks` cite the issues and the decisions by name; they remain valid
  without those topics, but the origin of a task is usually an issue. Tasks are
  folder documents (`TSK_NNN-title/`), with steps `TSK_NNN.XX`, according to the
  general rules.
