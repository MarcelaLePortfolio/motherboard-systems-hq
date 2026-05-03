# Phase 487 — Runtime Verifier Correction

## Classification
DESTRUCTIVE — Bounded single-file correction

## Why this is the safest next move
The current verification script is producing misleading results because it checks:
- `server/index.js` (not the real target in this repo)

This correction only updates the checker so it reflects reality better.

## Scope
- One file:
  - `scripts/_safety/phase487_runtime_verify.sh`

## Reversible
A backup is created first:
- `scripts/_safety/phase487_runtime_verify.sh.bak_phase487`

## Updated checks
The verifier will now check:
- `server.ts`
- `scripts/server.cjs`
- `scripts/agents/cade.ts`
- `scripts/agents/effie.ts`
- `agents/matilda.ts/matilda.mjs`
- launcher files

## Status
READY
