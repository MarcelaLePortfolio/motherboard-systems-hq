# Mission Control Presentation v1 — Claude Bundle Status

## Status

Ready for bounded Claude implementation handoff.

## Repository State

- Branch: `feature/new-ui-shell`
- Current commit: `32406583`
- Bundle path: `handoffs/mission-control-presentation-v1.zip`
- Bundle SHA-256:
  `84b38814841d96007d6f7c82f5e6c59de54a8d04a5cefafef00ea79e5a49a725`

## Verification

- Presentation Specification committed.
- Implementation Plan committed.
- Claude Task committed.
- Bundle Manifest included.
- Approved mockup included.
- Frontend implementation files included.
- SHA256SUMS included.
- Semantic drift guard passed.
- Repository pushed successfully.

## Bundle Contents

The bundle contains:

- `CLAUDE_TASK.md`
- `docs/MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md`
- `docs/MISSION_CONTROL_IMPLEMENTATION_PLAN_V1.md`
- approved Mission Control mockup
- Mission Dashboard frontend files
- Mission Read presentation files
- bundle manifest
- SHA256SUMS

## Architectural Boundary

This bundle authorizes only a bounded frontend implementation.

It does **not** authorize modifications to:

- backend runtime,
- database schema,
- Mission Read backend,
- governance runtime,
- package semantics,
- delegation semantics,
- envelope semantics,
- project context,
- conversation runtime,
- routing,
- disaster recovery tooling,
- semantic drift tooling.

## Definition of Success

A successful Claude implementation will:

- preserve all existing Mission Read runtime behavior,
- reproduce the approved Mission Control presentation,
- preserve architectural invariants,
- preserve semantic correctness,
- modify only the bounded frontend files,
- pass the client build,
- pass the semantic drift guard,
- pass `git diff --check`.

## Next Authorized Action

Provide:

`handoffs/mission-control-presentation-v1.zip`

to Claude.

Claude should begin by reading:

1. `CLAUDE_TASK.md`
2. `MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md`
3. `MISSION_CONTROL_IMPLEMENTATION_PLAN_V1.md`

before modifying any code.

If implementation requires backend changes or files outside the bounded bundle, Claude must stop and report the dependency instead of expanding scope.
