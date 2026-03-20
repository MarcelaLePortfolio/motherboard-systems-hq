# Post-Golden Protection Routine

Date: 2026-03-20

## Purpose
Establish a repeatable, non-destructive protection routine to run immediately after any golden checkpoint.

## Scope
This routine is intentionally protective only.

It does not:
- expand architecture
- change authority model
- introduce speculative refactors
- rewrite runtime behavior
- containerize by assumption

It does:
- verify repo cleanliness
- verify current branch and tags
- verify tests
- inspect container-related assets if present
- inspect workflow and runtime protection files
- capture a hardening snapshot for next action

## Routine Steps
1. Verify git status is clean
2. Verify current branch
3. Verify latest golden tag exists
4. Re-run deterministic tests relevant to the just-closed phase
5. Inspect Docker / container assets if present
6. Inspect CI / workflow files if present
7. Inspect local runtime scripts if present
8. Record findings in a hardening snapshot
9. Only after snapshot, choose next bounded protection task

## Containerization Rule
Containerization is allowed only after:
- current golden is verified
- container assets are inventoried
- no unresolved runtime mismatch exists
- change scope is explicit

Containerization is not treated as routine by default.
It is a separate bounded task after audit.

## Current Decision
Next safe move after Phase 95 golden:
- run protection audit
- record snapshot
- then decide whether containerization is warranted

