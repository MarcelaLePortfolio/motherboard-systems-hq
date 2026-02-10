# Phase 36.3 — Run List Observability (PLANNING ONLY)

## Goal
Define a read-only, canonical interface for listing runs (multi-row observability) with DB as source of truth.

## Scope (Planning Only)
- Define API contract for a run list endpoint
- Define backing SQL source (view preferred) and invariants
- Define safety limits, ordering, and filter semantics
- No implementation, no UI wiring, no worker changes

## Non-Goals
- No writes or mutations
- No changes to worker leasing/claiming/reclaim
- No pagination implementation (only define contract)
- No UI changes beyond planning notes

## Proposed Endpoint
- GET /api/runs

## Canonical Source
- SQL view: run_view (current)
- Note: run_view does NOT expose created_at/updated_at; it exposes event/heartbeat timestamps in epoch-ms.

## Ordering (Deterministic)
- last_event_ts DESC NULLS LAST
- last_event_id DESC NULLS LAST
- run_id DESC (tie-break)

Rationale: matches run_view’s own determinism (latest event per run_id), avoids UI-derived state.

## Query Parameters (Contract)
All optional. Server must apply deterministic defaults.

- limit (int)
  - default: 50
  - max: 200

- cursor (string)
  - opaque cursor for future pagination (contract only)

- task_status (string or CSV)
  - exact match against run_view.task_status (values enumerated by probe script)

- is_terminal (boolean)
  - exact match against run_view.is_terminal

- since_ts (epoch-ms bigint)
  - filter by last_event_ts >= since_ts
  - NOTE: run_view uses epoch-ms; avoid RFC3339 conversion in v1 contract.

## Response Shape (Contract)
{
  "ok": true,
  "data": {
    "items": [
      {
        "run_id": "r123",
        "task_id": "t30",
        "actor": "docker-wA",
        "task_status": "running",
        "is_terminal": false,
        "last_event_kind": "heartbeat",
        "last_event_ts": 1770000000000,
        "last_event_id": 123,
        "last_heartbeat_ts": 1770000000000,
        "heartbeat_age_ms": 0,
        "lease_expires_at": 1770000010000,
        "lease_fresh": true,
        "lease_ttl_ms": 10000,
        "terminal_event_kind": null,
        "terminal_event_ts": null,
        "terminal_event_id": null
      }
    ],
    "next_cursor": null
  }
}

Notes:
- Fields must come directly from SQL (no UI-derived / JS-derived state).
- next_cursor is part of the contract but may remain null until pagination is implemented.

## SQL Source (Planning)
Option A (preferred): runs_list_view (projection of run_view)
- one row per run_id (inherited)
- strict projection of list-safe fields only
- stable ordering based on last_event_ts/last_event_id/run_id

Option B: deterministic SELECT from run_view (no new view)
- acceptable if it stays simple and stable

## Invariants
- Read-only
- DB is source of truth
- Deterministic ordering
- Idempotent responses for same DB state
- No UI- or JS-derived state beyond serialization

## Validation Probe (Dev)
- scripts/phase36_3_probe_run_view.sh

Use output to:
- confirm list fields
- enumerate canonical task_status values
- sanity-check event-kind distributions

## Exit Criteria (Planning)
- API contract locked (params + response fields)
- SQL source chosen (run_view projection vs runs_list_view)
- Ordering + limits locked
- Non-goals explicit
