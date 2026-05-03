# Phase 487 — CORS Restore Execution

## Classification
DESTRUCTIVE — Minimal dependency restoration

## Why this is the safest next move
Audit established that:

- `cors` is referenced by active server-related surfaces
- `cors` appears in prior package history
- the main live-start probe failed specifically because `cors` was missing

This is a narrow runtime dependency restoration, not a broad repair corridor.

## Impact surface
- `package.json`
- `pnpm-lock.yaml`
- installed node dependencies

## Why this is acceptable
- no source logic change
- no file deletion
- no route mutation
- directly addresses the first concrete runtime blocker
- easy to audit afterward with the same bounded live-start probe

## Follow-up
After restoring `cors`:
1. rerun the same `server.ts` live-start probe
2. stop at the next concrete blocker or first successful boot

## Status
READY
