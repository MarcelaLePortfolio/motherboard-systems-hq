# Phase 487 — task_events Backup Restore Execution

## Classification
DESTRUCTIVE — Minimal database restoration

## Why this is the safest next move
Audit established that:

- `db/main.db` exists but is 0 bytes
- `task_events` is missing from the active database
- multiple local backup databases already contain:
  - `task_events`
  - `reflection_index`
- the narrowest justified recovery is to restore `db/main.db` from the best local backup source rather than inventing schema/data manually

## Chosen restoration source
`db/main_backup_before_rebuild.sqlite`

Reason:
- contains both required tables
- contains the highest observed `task_events` count among the audited backups
- is a local repo-adjacent recovery source, not an external guess

## Impact surface
- `db/main.db`
- one backup snapshot of the current zero-byte `db/main.db`
- probe output document

## Why this is acceptable
- no source logic change
- no dependency change
- no route mutation
- restores a concrete missing runtime prerequisite from an audited local source

## Follow-up
After restore:
1. rerun the same bounded `server.ts` live-start probe
2. stop at the next concrete blocker or first successful boot

## Status
READY
