# Phase 37 — Run Projection Contract (Planning Only)

## Purpose
Formalize a deterministic contract for `run_view` under:
- **single-writer** `task_events`
- **read-only** observability endpoints
- **SQL-only** derivation (no inferred JS state)

## Canonical Ordering Key (Required)
Any ordering used for projection MUST be total and deterministic:
- Primary: `task_events.ts` (ascending)
- Tie-breaker: `task_events.id` (ascending)

---

## `run_view` Field Inventory (Captured from Postgres)

| # | column | type | char_len | num_prec | num_scale | nullable |
|---:|---|---|---:|---:|---:|---|
| 1 | `run_id` | text |  |  |  | YES |
| 2 | `task_id` | text |  |  |  | YES |
| 3 | `actor` | text |  |  |  | YES |
| 4 | `lease_expires_at` | bigint |  | 64 | 0 | YES |
| 5 | `lease_fresh` | boolean |  |  |  | YES |
| 6 | `lease_ttl_ms` | bigint |  | 64 | 0 | YES |
| 7 | `last_heartbeat_ts` | bigint |  | 64 | 0 | YES |
| 8 | `heartbeat_age_ms` | bigint |  | 64 | 0 | YES |
| 9 | `last_event_id` | bigint |  | 64 | 0 | YES |
| 10 | `last_event_ts` | bigint |  | 64 | 0 | YES |
| 11 | `last_event_kind` | text |  |  |  | YES |
| 12 | `task_status` | text |  |  |  | YES |
| 13 | `is_terminal` | boolean |  |  |  | YES |
| 14 | `terminal_event_kind` | text |  |  |  | YES |
| 15 | `terminal_event_ts` | bigint |  | 64 | 0 | YES |
| 16 | `terminal_event_id` | bigint |  | 64 | 0 | YES |

---

## Field Provenance Matrix (To Fill)
For each `run_view` column, record:
- Source(s) (table/event types)
- Deterministic SQL rule
- “Latest” semantics (by canonical ordering)
- Nullability semantics
- Stability requirement (same DB state => same result)

Template:

### `<column_name>`
- Source(s):
- Rule:
- Latest semantics:
- Nullability:
- Stability requirement:

---

## Invariants
### A) Provenance (Explainability)
Every field is sourced from sanctioned DB inputs or deterministically derived in SQL.

### B) Temporal Coherence (No Time Travel)
For a given `run_id`, the snapshot aligns to one event timeline and uses an unambiguous “latest”.

### C) Closed World
No hidden state: no caches, no worker-only memory, no JS-derived state.

---

## Planning Acceptance Checks (Defined, Not Implemented)
1) Ordering determinism
2) Traceability spot audit per run_id
3) Snapshot coherence vs last relevant event

---

## Protocols
- Golden tags are immutable (Phase 36 tag is authoritative).
- Phase 37.0 is docs-only: no schema, no endpoints, no worker changes.
- 3 failed attempts per hypothesis in later phases => revert to last stable baseline.

