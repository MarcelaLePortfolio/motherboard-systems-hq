
# Artifact Snapshot Builder

## Purpose

Deterministically capture current repository + runtime-adjacent state.

## Scope

READ-ONLY ONLY.

This layer:

- reads repository structure

- reads runtime-adjacent metadata

- produces structured snapshot artifacts

- does NOT mutate runtime state

- does NOT execute diffs

- does NOT perform reconciliation

## Initial Outputs

- repository tree

- git commit state

- PM2 process state

- tunnel status metadata

- container/runtime metadata

- timestamped snapshot manifest

## Invariants

- deterministic

- observable

- reproducible

- rollback-safe

- non-mutating

## Future Consumers

- preview/diff layer

- Matilda semantic interpretation layer

- execution bridge layer

- reconciliation layer

