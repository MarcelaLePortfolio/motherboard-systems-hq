# Phase 37.1 — Terminal Event Provenance (Planning Only)

## Protocols (hard)
- Planning-only docs.
- NO schema changes.
- NO view edits.
- NO worker changes.
- Canonical ordering definition for “latest” semantics:
  - `task_events.ts` ASC
  - tie-breaker: `task_events.id` ASC

## Authority + Lens
- Authority: `PHASE37_RUN_VIEW_DEFINITION.sql`
- Validation lens: `PHASE37_ACCEPTANCE_CHECKS.sql` (terminal checks §4a / §4b)

---

## What `run_view` says (authoritative, as captured)

### terminal_event_kind / terminal_event_ts / terminal_event_id
Source of truth in the view is the `terminal_event` CTE:

- Source table: `public.task_events` (filtered to `run_id IS NOT NULL`)
- Terminal predicate (as implemented in the view):
  - `te.kind IN ('completed','failed','canceled','cancelled')` (exact spellings, as written)
- Selection rule:
  - `SELECT DISTINCT ON (task_id, run_id) ... ORDER BY id DESC`
- Projections:
  - `terminal_event_kind = te.kind`
  - `terminal_event_ts   = te.ts`
  - `terminal_event_id   = te.id`

Notes:
- The view’s terminal selection is **latest-by-id** within `(task_id, run_id)`, not explicitly by `(ts, id)`.
- The view then joins `terminal_event` back onto the per-run row (via `task_id, run_id`).

### is_terminal
- Derived from `tasks.status` (as implemented):
  - `is_terminal = (t.status IN ('completed','failed','canceled','cancelled'))`
- This is not sourced from `task_events.kind`; it is sourced from `tasks.status`.

---

## Canonical (contract) definition we are enforcing (Phase 37 ordering rule)

For each `run_id`:
- The canonical timeline order is `ORDER BY task_events.ts ASC, task_events.id ASC`.
- The “latest terminal event” for a `run_id` (if any) is the row with MAX `(ts, id)` among events whose `kind` is terminal (per the contract’s terminal-kind set).

Canonical extraction pattern (per-run):
- `SELECT DISTINCT ON (run_id) ... FROM task_events WHERE run_id IS NOT NULL AND kind IN (...) ORDER BY run_id, ts DESC, id DESC`

---

## Validation lens mismatch (observed)

`PHASE37_ACCEPTANCE_CHECKS.sql` currently defines terminal kinds as:

- `kind IN ('task.completed','task.failed','task.cancelled')`

But `run_view` terminal predicate (as captured) is:

- `kind IN ('completed','failed','canceled','cancelled')`

As a result, acceptance §4a and §4b can legitimately report mismatches even when `run_view` is internally consistent with its own definition.

This is expected until the contract and the view agree on:
1) The terminal-kind namespace (e.g., `task.completed` vs `completed`), and
2) The “latest” selection rule (canonical `(ts,id)` vs view’s `(id)` within `(task_id, run_id)`).

---

## Stop condition for Phase 37.1 (planning-only)
- This document records terminal provenance mechanically and captures the specific contract/view kind-namespace mismatch.
- No implementation changes are made in Phase 37.1.
