# Phase 41 — Prove Decision-Correctness (Read-Only)

## Goal
Add a **deterministic scenario matrix** and **read-only invariants** that validate claim/reclaim/terminal outcomes **without influencing worker behavior**.

## Hard Rule
If any invariant fails, revert to:
- v40.6-shadow-audit-task-events-green

## Scope
- Add SQL-only invariant checks that read from canonical projections (prefer: run_view)
- Add scenario classification matrix (deterministic CASE mapping) for every run row
- Add a gate script that fails fast if any invariant is violated

## Non-Goals
- No worker code changes
- No schema changes
- No behavioral changes to claim/reclaim
- No writes (invariant checks are read-only)

## Entry Points
- scripts/phase41_invariants_gate.sh
- sql/phase41_invariants_run_view.sql
- sql/phase41_scenario_matrix_run_view.sql
