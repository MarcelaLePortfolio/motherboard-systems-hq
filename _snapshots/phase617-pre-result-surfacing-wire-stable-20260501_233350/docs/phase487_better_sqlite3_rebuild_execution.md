# Phase 487 — better-sqlite3 Native Rebuild Execution

## Classification
DESTRUCTIVE — Minimal local dependency rebuild

## Why this is the safest next move
Audit established that:

- `better-sqlite3` is an intended runtime dependency
- the installed package exists locally
- Node 24.4.0 is within the package's declared supported range
- the current blocker is not a missing package, but a missing native binding artifact

This means the narrowest justified next move is to rebuild the native module locally before considering any broader environment change.

## Impact surface
- local `node_modules` native build artifacts only

## Why this is acceptable
- no source logic change
- no file deletion
- no route mutation
- no package version change
- directly addresses the next concrete runtime blocker

## Follow-up
After rebuild:
1. rerun the same `server.ts` live-start probe
2. stop at the next concrete blocker or first successful boot

## Status
READY
