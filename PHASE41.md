# Phase 41 — Prove Decision-Correctness (Read-Only)

## Goal
Add a deterministic scenario matrix + read-only invariants that validate claim/reclaim/terminal outcomes without influencing worker behavior.

## Hard Rule
If any invariant fails, revert to:
- v40.6-shadow-audit-task-events-green

## Canonical Source
All checks are SQL-only and read from `run_view` (read-only).

### run_view columns (current)
- run_id, task_id
- actor
- lease_expires_at, lease_fresh, lease_ttl_ms
- last_heartbeat_ts, heartbeat_age_ms
- last_event_id, last_event_ts, last_event_kind
- task_status
- is_terminal
- terminal_event_kind, terminal_event_ts, terminal_event_id

## Entry Points
- sql/phase41_invariants_run_view.sql
- sql/phase41_scenario_matrix_run_view.sql
- scripts/phase41_invariants_gate.sh
- scripts/phase41_scenario_matrix_dump.sh
- scripts/phase41_smoke.sh
- scripts/phase41_revert_to_v40_6_if_fail.sh

## Non-Goals
- No worker code changes
- No schema changes
- No behavioral changes to claim/reclaim
- No writes (invariant checks are read-only)

## How to Run
- `scripts/phase41_invariants_gate.sh`
- `scripts/phase41_smoke.sh`

## Revert Procedure (deterministic)
- `scripts/phase41_revert_to_v40_6_if_fail.sh`
