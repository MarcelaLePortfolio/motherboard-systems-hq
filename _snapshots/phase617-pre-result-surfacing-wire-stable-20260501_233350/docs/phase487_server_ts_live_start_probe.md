# Phase 487 — server.ts Live Start Probe

## Classification
SAFE — Observational live-start attempt

## Purpose
Start only the most likely primary runtime target:

- `server.ts`

This step is not a repair step.
It is a bounded observation step to answer one question only:

**Can the current main surface boot at all?**

## Constraint
- No code mutation
- No deletion
- No Docker work
- No broad scope expansion
- Stop after first real runtime signal

## What this does
1. Starts `server.ts`
2. Captures startup output
3. Checks whether port 3001 begins listening
4. Probes `/diagnostics/systemHealth`
5. Stops the process cleanly

## Status
READY
