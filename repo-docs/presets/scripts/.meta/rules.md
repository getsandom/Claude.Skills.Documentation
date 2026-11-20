# Rules: scripts

- **Identifier:** none
- **Template:** none
- **File name:** the usual name for the script's platform (e.g. `Register-EventSource.ps1`, `install.sh`)
- **Index description:** what the script does, its main parameters and where its usage is described
- **On closing:** remove the file when no guide cites it anymore and record it in the history; there is no Closed section
- **Subtopics:** none

## What to record

Installation and operation scripts cited by the support guides. Development or
build scripts live in the code, outside this folder.

## Lifecycle

- Every script is cited by at least one support guide, which describes its usage.
- The script header describes what it does and its parameters.
- When changing parameters or behavior, update the guide that cites it.
