# Phase 487 — /delegate Minimal Alignment Fix

## Classification
DESTRUCTIVE — Single-file route alignment fix

## Why this is the safest next move
Live probe established:

- `/tasks/recent` fixed and stable
- `/logs/recent` stable
- `/delegate` fails with:
  SqliteError: table task_events has no column named agent

This is the exact same class of failure we already resolved for `/tasks/recent`.

## Root cause
`task_events` table contains only:

- id
- type
- status
- created_at

But `/delegate` is attempting to insert:

- agent
- payload
- result

## Strategy
Align the INSERT to the live schema while preserving system behavior.

- map:
  type → incoming task type
  status → "queued" (or equivalent)
  created_at → CURRENT_TIMESTAMP

- remove:
  agent
  payload
  result

## Impact surface
- routes/api/delegate.ts
- one backup file

## Why this is acceptable
- no DB mutation
- no schema rewrite
- no cross-route refactor
- resolves one concrete runtime blocker only

## Status
READY
