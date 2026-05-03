# Phase 39 — Action Tier Scaffolding (Structural Value-Alignment)

## Goal
Introduce structural value-alignment scaffolding by adding:
- `action_tier` metadata (default = `A`)
- schema validation for tier disclosure fields
- a pre-execution worker gate (Tier A allowed; Tier B/C fail-fast)

## Invariants
- No UI changes
- No behavior expansion
- All existing flows remain Tier A (default)
- B/C tasks are blocked in the worker before any execution occurs

## Scope
1) DB: add `tasks.action_tier` with default `A`, plus optional disclosure fields (nullable)
2) API: validate incoming create payload:
   - action_tier defaults to A
   - if action_tier != A, require disclosure fields (non-empty)
3) Worker: gate check:
   - allow A
   - fail-fast B/C with deterministic error, do not execute
