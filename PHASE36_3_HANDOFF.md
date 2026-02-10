# Phase 36.3 — Handoff (Planning Only)

## What changed
- Planning contract updated to align with actual SQL `run_view` (epoch-ms timestamps; deterministic ordering by last_event_ts / last_event_id / run_id).
- Added validation probe script: `scripts/phase36_3_probe_run_view.sh`.

## Validation results (dev)
From `scripts/phase36_3_probe_run_view.sh`:
- `run_view` columns confirmed:
  - run_id, task_id, actor
  - lease_expires_at, lease_fresh, lease_ttl_ms
  - last_heartbeat_ts, heartbeat_age_ms
  - last_event_id, last_event_ts, last_event_kind
  - task_status, is_terminal
  - terminal_event_kind, terminal_event_ts, terminal_event_id
- Distinct `task_status` currently observed: `completed` only.
- Distinct `last_event_kind` currently observed: `completed`, `task.completed`.

## Decisions locked (planning)
- Run list ordering:
  - last_event_ts DESC NULLS LAST
  - last_event_id DESC NULLS LAST
  - run_id DESC
- Contract timestamps use epoch-ms (avoid RFC3339 conversion in v1 contract).
- Filters in contract prefer SQL-native fields:
  - task_status, is_terminal, since_ts (epoch-ms)

## Next (implementation later; NOT in 36.3)
- Decide whether to:
  - add `runs_list_view` as a projection of `run_view`, or
  - keep a deterministic SELECT from `run_view`.
- Implement `GET /api/runs` (future phase): read-only, DB truth, no UI-derived state, no writes.

## Protocols
- zsh; `set -euo pipefail` + `setopt NO_BANG_HIST`
- DB is source of truth; deterministic/idempotent; no scope creep
- small logical commits; tag/push only via safe aliases; never push `stash-*` or `*DO_NOT_APPLY*` tags
