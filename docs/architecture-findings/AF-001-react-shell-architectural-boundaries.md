# AF-001 — React Shell Architectural Boundaries

Status: Accepted

Confidence: High

## Question

Is the React shell coupled to backend implementation or legacy dashboard behavior?

## Evidence

### Repository Evidence

Repository inspection of:

- client/src/shell/Shell.tsx
- client/src/shell/NavigationRegion.tsx
- client/src/shell/WorkspaceMount.tsx
- client/src/shell/PlaceholderWorkspace.tsx

### Reasoning

Inspection showed that the shell composes structural UI regions without embedding backend communication, routing, project semantics, or execution behavior. Each inspected component maintained a presentational responsibility, supporting the conclusion that the shell currently serves as an architectural composition layer rather than a domain implementation layer.

## Finding

The React shell is architecturally presentation-only.

The shell currently owns layout and composition but does not contain:

- backend communication
- routing decisions
- project semantics
- workspace semantics
- execution logic

NavigationRegion and WorkspaceMount are structural extension points rather than feature implementations.

## Implications

Backend integration should occur through explicit adapters rather than direct shell coupling.

Navigation remains an independent architectural decision rather than a prerequisite for shell implementation.

Future work should preserve these boundaries.

## Supersedes

None.
