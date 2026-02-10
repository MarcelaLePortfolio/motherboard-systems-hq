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

## Query Parameters (Contract)
All optional. Server must apply deterministic defaults.

- limit (int)
  - default: 50
  - max: 200
- cursor (string)
  - opaque cursor for future pagination (contract only)
- status (string or CSV)
  - exact match against SQL status values
- since (RFC3339 timestamp)
  - applies to updated_at OR created_at (decision required)
- task_id (string)
  - optional filter if present in SQL source

## Ordering (Deterministic)
- created_at DESC
- run_id DESC (tie-break)

## Response Shape (Contract)
{
  "ok": true,
  "data": {
    "items": [
      {
        "run_id": "r123",
        "task_id": "t30",
        "status": "running",
        "actor": "docker-wA",
        "created_at": "2026-02-10T00:00:00.000Z",
        "updated_at": "2026-02-10T00:00:00.000Z"
      }
    ],
    "next_cursor": null
  }
}

## SQL Source (Planning)
Preferred:
- runs_list_view (projection of run_view)
Requirements:
- One row per run_id
- Deterministic fields only
- No volatile expressions

Alternative:
- Deterministic SELECT from run_view (no new view)

## Invariants
- Read-only
- DB is source of truth
- Deterministic ordering
- Idempotent responses
- No UI- or JS-derived state

## Open Questions
1) since applies to updated_at or created_at?
2) Canonical status set?
3) Is task_id filter required in v1?
4) Cursor based on (created_at, run_id)?
5) Env-specific limits?

## Exit Criteria (Planning)
- API contract locked
- SQL source chosen
- Ordering and limits locked
- Non-goals explicit
