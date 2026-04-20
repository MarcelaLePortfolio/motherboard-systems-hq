# Phase 487 — Next Step: Safe Runtime Verification

## Classification
SAFE — Read-only verification (no mutations, no deletions, no state changes)

## Purpose
Now that:
- Disk pressure is resolved
- Git storage is stabilized
- Protocol enforcement is locked

We must verify that **runtime behavior is still intact** after cleanup.

## What This Verifies
- Agent launch capability
- Server boot integrity
- Missing dependency detection
- Runtime path expectations (memory/logs/etc.)

## Commands

### 1. Install dependencies (no changes if already installed)
pnpm install || npm install

### 2. Typecheck (no emit)
pnpm tsc --noEmit || npx tsc --noEmit

### 3. Start server (observe only)
pnpm start || npm start || node server/index.js

### 4. Optional: run agent launchers individually
node scripts/_local/agent-runtime/launch-cade.ts
node scripts/_local/agent-runtime/launch-matilda.ts
node scripts/_local/agent-runtime/launch-effie.ts

## What to Watch For

### GOOD signals
- Server starts without crash
- Agents initialize
- No missing file/module errors

### WARNING signals
- Errors referencing:
  - agents/cade.ts
  - agents/effie.ts
  - memory/*
  - logs/*
  - ticker-events.log

These indicate runtime dependencies that may need restoration or redirection.

## Constraint
This step:
- Does NOT modify files
- Does NOT delete anything
- Does NOT alter git state

## Outcome

If runtime succeeds:
→ Cleanup is confirmed safe

If runtime fails:
→ We enter **targeted restoration corridor**
→ No further cleanup is performed

## Status
READY — Execute next to validate system integrity
