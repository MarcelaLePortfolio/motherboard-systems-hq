# Phase 487 — Narrowed Runtime Verification Plan

## Classification
SAFE — Read-only, bounded verification

## Purpose
Verify only the surfaces that matter for the current operator corridor.

## Runtime-critical targets
- `server.ts`
- `scripts/server.cjs`
- `routes/api/delegate.ts`
- `routes/api/tasks.ts`
- `routes/api/logs.ts`
- `routes/diagnostics/systemHealth.ts`
- `scripts/agents/cade.ts`
- `scripts/agents/effie.ts`
- `agents/matilda.ts/matilda.mjs`

## Goal
Answer the real question:
Is the current runtime surface structurally intact enough to continue Phase 487?

## Method
- confirm files exist
- inspect bounded file headers
- inspect import lines only
- avoid full-repo type expansion
- avoid mutation

## Status
READY
