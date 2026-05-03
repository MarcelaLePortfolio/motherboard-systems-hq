# Phase 487 — pnpm Build Policy Correction Execution

## Classification
DESTRUCTIVE — Minimal project config correction

## Why this is the safest next move
Audit established that:

- the native build blocker is not random
- `better-sqlite3` is explicitly present in project-level pnpm build policy
- pnpm config is currently reporting `ignored-built-dependencies[]=better-sqlite3`
- rebuild attempts will keep failing until that policy is corrected

This means the narrowest justified next move is to correct the project-level build policy, then rebuild the native module again.

## Impact surface
- `pnpm-workspace.yaml`
- local `node_modules` native build artifacts only

## Why this is acceptable
- no source logic change
- no route mutation
- no package version change
- directly addresses the actual blocker in front of the live runtime surface

## Follow-up
After config correction:
1. rebuild `better-sqlite3`
2. rerun the same bounded `server.ts` live-start probe
3. stop at the next concrete blocker or first successful boot

## Status
READY
