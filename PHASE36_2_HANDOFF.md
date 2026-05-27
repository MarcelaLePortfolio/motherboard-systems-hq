# Phase 36.2 — Run-Centric Observability (Handoff)

## Status
✅ COMPLETE — smoke green

## Branch
feature/phase36-2-run-observability

## What shipped
- Read-only endpoint: GET /api/runs/:run_id
- Query is backed strictly by SQL view: run_view
- No writes, no UI-derived state, returns 1 row per run_id (LIMIT 1)
- Response keys mirror run_view column names (no renames)

## Key fix
Dashboard container was serving old code (container age ~3 days). Rebuild/recreate required:
- `docker compose up -d --build dashboard`

Also, route now falls back to PG* env vars when POSTGRES_URL/DATABASE_URL missing:
- PGHOST/PGPORT/PGUSER/PGPASSWORD/PGDATABASE

## Proof
- Smoke script: scripts/phase36_2_run_observability_smoke.sh
- Latest run: returns 200 + ASSERT_OK (task_status=completed, is_terminal=true, terminal_event_kind=completed)

## Tags
- v36.0-worker-steady-after-recovery
- v36.1-phase36-2-run-observability-smoke-green

## Protocols (locked)
- zsh
- set -euo pipefail
- setopt NO_BANG_HIST
- commands in fenced blocks
- no scope creep
- DB is source of truth; deterministic/idempotent
- small logical commits
- only tag/push via safe aliases
- never push stash-* or *DO_NOT_APPLY* tags
