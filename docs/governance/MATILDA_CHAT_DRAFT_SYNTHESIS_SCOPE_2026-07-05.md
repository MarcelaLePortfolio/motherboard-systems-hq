
# Matilda Chat Draft Synthesis Scope

Date: 2026-07-05

## Corridor

Matilda Chat → IEL → Living Draft Synthesis

## Current Stable Checkpoint

HEAD: ea75bb95

Latest DR: 20260705_225520

## Objective

Wire normal Matilda chat so each interaction preserves IEL evidence and then updates the non-authoritative Living Draft Package.

## In Scope

- Use the existing `/api/chat` path.

- Preserve the existing IEL entry creation.

- Trigger Living Draft synthesis after IEL persistence.

- Keep the Living Draft non-authoritative.

- Preserve governance boundary flags.

## Out of Scope

- Canonical Package creation.

- Approval handling.

- Delegation.

- Ellis validation.

- Atlas readiness scoring.

- Envelope creation.

- Cade execution.

## Success Criteria

A normal Matilda chat message:

1. returns a normal Matilda response

2. creates an IEL entry

3. updates the Living Draft Package

4. does not create a Canonical Package

5. does not authorize Delegation, Validation, Envelope creation, routing, assignment, or Cade execution

