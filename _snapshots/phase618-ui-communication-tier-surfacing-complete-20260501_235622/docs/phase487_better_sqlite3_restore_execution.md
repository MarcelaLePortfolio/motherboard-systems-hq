# Phase 487 — better-sqlite3 Restore Execution

## Classification
DESTRUCTIVE — Minimal dependency restoration

## Why this is the safest next move
Audit established that:

- `better-sqlite3` is referenced by active runtime surfaces
- it exists in prior package history
- `db/client.ts` directly depends on it
- the main live-start probe failed specifically because it was missing

This is a narrow runtime dependency restoration, not a broad repair corridor.

## Impact surface
- `package.json`
- `pnpm-lock.yaml`
- installed node dependencies

## Why this is acceptable
- no source logic change
- no file deletion
- no route mutation
- directly addresses the next concrete runtime blocker
- easy to audit afterward with the same bounded live-start probe

## Follow-up
After restoring `better-sqlite3`:
1. rerun the same `server.ts` live-start probe
2. stop at the next concrete blocker or first successful boot

## Status
READY
