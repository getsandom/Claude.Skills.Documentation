# Architecture template

```markdown
# Component name

- **State:** Implemented | Partial | Planned
- **Code:** projects, modules or packages involved
- **Updated:** YYYY-MM-DD

## Responsibility

What the component does and, if helpful, what it explicitly does not do.

## Overview

How the parts relate to each other. A diagram (Mermaid or ASCII) when the structure
does not fit well in text.

## Flow

Step by step of the main path and of the relevant failure paths.

## Contracts

Interfaces, requests and responses, tables or messages that other components use.

## Rules and invariants

What must always be true.

## Configuration

Adjustable parameters, their default values and where they are defined.

## Differences between planned and implemented

Mandatory when the state is Partial or Planned: what the code does today and
what is still missing.

## References

- Related decisions and issues (links)
- Code: paths of the main files
```
