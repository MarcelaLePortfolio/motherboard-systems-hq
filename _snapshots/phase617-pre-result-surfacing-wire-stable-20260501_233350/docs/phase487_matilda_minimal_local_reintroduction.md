# Phase 487 — Matilda Minimal Local Reintroduction

## Classification
DESTRUCTIVE — Single-file route refinement

## Why this is the safest next move
The source audit proved that the historical Matilda module depends on Ollama and shell execution.

That violates the current stop condition:

- Matilda must return 200
- return a string reply
- not crash
- not depend on other systems

So the safest move is **not** to restore the old Matilda module yet.

## Decision
Replace the temporary fallback with a **deterministic local reply handler** inside `server.ts`.

## Behavior goals
- Keep `/matilda` alive
- Keep response shape intact: `{ reply: "..." }`
- No external imports
- No agent wiring
- No DB dependency
- No shell dependency

## Reply policy
- Empty / missing message → gentle prompt
- Greeting → friendly deterministic greeting
- Everything else → acknowledge receipt and state that deeper Matilda wiring is pending

## Impact surface
- `server.ts`
- one same-folder backup file

## Why this is acceptable
- no schema mutation
- no dependency mutation
- no multi-route edits
- no speculative restoration
- upgrades Matilda from fallback placeholder to stable deterministic local behavior

## Follow-up
After patch:
1. rerun bounded live probe for `/matilda`
2. confirm `/tasks/recent`, `/logs/recent`, and `/delegate` remain stable
3. stop at checkpoint

## Status
READY
