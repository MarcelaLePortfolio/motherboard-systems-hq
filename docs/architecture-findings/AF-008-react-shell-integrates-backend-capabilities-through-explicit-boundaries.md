# AF-008 — React Shell Integrates Backend Capabilities Through Explicit Boundaries

Status: Accepted

Confidence: High

## Question

How should backend capabilities be incorporated into the React shell?

## Evidence

### Repository Evidence

Repository inspection established that:

- The React shell contains no embedded Project Registry behavior.
- The shell exposes generic composition points through `NavigationRegion` and `WorkspaceMount`.
- The Project Registry backend operates independently of the React shell.

### Reasoning

The shell has been structured as a presentation and composition layer rather than as the owner of application capabilities. Backend capabilities exist independently and should be connected through explicit integration boundaries rather than embedded directly into shell components.

## Finding

The React shell integrates backend capabilities through explicit integration boundaries.

Capabilities should be introduced by consuming stable backend contracts through dedicated integration layers while preserving the shell's role as a presentation and composition framework.

## Implications

Future capabilities should follow the same architectural pattern, allowing the shell to remain generic while backend systems remain authoritative for application behavior.

Integration work should prioritize reuse of existing backend capabilities over reimplementation within the frontend.

## Supersedes

None.
