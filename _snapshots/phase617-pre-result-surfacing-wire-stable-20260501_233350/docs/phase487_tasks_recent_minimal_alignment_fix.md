# Phase 487 — /tasks/recent Minimal Alignment Fix

## Classification
DESTRUCTIVE — Single-file route alignment fix

## Why this is the safest next move
Audit established that:

- the server now boots successfully
- `/tasks/recent` fails because the live `task_events` table does not contain:
  - `agent`
  - `payload`
  - `result`
- the current table does contain:
  - `id`
  - `type`
  - `status`
  - `created_at`

This means the narrowest justified next move is to align the route query to the live schema while preserving the response shape for consumers.

## Response-shape preservation
The route will continue returning:

- `id`
- `type`
- `agent`
- `status`
- `payload`
- `result`
- `created_at`

For the columns that do not exist in the restored table, the route will return `NULL` placeholders.

## Impact surface
- `routes/api/tasks.ts`
- one same-folder backup of the original file

## Why this is acceptable
- no database mutation
- no dependency mutation
- no broad refactor
- no route expansion
- fixes one concrete live failure only

## Follow-up
After patch:
1. rerun a bounded live probe for `/tasks/recent`
2. stop at the next concrete blocker or first successful response

## Status
READY
