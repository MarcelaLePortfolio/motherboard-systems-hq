# Phase 36.5 — Run List UX + Deterministic Filters (Dashboard)

## Goal
Expose the new **read-only** run list endpoint in the dashboard with **zero UI inference** and a deterministic query surface.

## Inputs (Source of Truth)
- API: `GET /api/runs`
- SQL view: `run_view` (canonical; no derived JS state)

## Scope
- Add a Runs panel/table (or extend existing runs inspection UI) that:
  - Fetches `/api/runs?limit=...&task_status=...&is_terminal=...&since_ts=...`
  - Renders returned rows exactly as received
  - Supports deterministic client controls:
    - limit (1..200, default 50)
    - task_status (multi-select; repeated query keys)
    - is_terminal (true/false/blank)
    - since_ts (epoch-ms) OR a simple "last X minutes" that converts to since_ts client-side

## Non-Goals / Guardrails
- No mutations
- No server writes
- No "computed" statuses in UI
- No pagination unless deterministic and fully server-driven later
- No new backend routes beyond `/api/runs` (already shipped)

## Determinism Rules
- Server ordering is canonical:
  - `last_event_ts DESC NULLS LAST, last_event_id DESC NULLS LAST, run_id DESC`
- UI must not re-sort by default; if user sorts, it must be explicit and reversible.

## Definition of Done
- Dashboard shows last N runs (default 50) from `/api/runs`
- Filters work and match server results
- A smoke flow exists:
  - Start server
  - Open dashboard
  - Confirm table populates
  - Confirm filters change query string and results

## Notes
- Run rows include: run_id, task_id, task_status, is_terminal, last_event_id, last_event_ts, last_event_kind, actor,
  lease_expires_at, lease_fresh, lease_ttl_ms, last_heartbeat_ts, heartbeat_age_ms, terminal_event_kind, terminal_event_ts, terminal_event_id
