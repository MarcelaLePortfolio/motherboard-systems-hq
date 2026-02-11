# Phase 37 — run_view Provenance Hints (Auto-Extracted, Planning Only)

This file is **best-effort** automation to speed up filling:
- `PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md`

It extracts the `SELECT ... AS <column>` expressions from the captured
`PHASE37_RUN_VIEW_DEFINITION.sql`. Treat as hints, not truth.

Canonical ordering key remains:
- `task_events.ts` ASC, tie-breaker `task_events.id` ASC

---

## run_id
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## task_id
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## actor
- Candidate expression(s):
  - `''::text)) AS actor`

- Likely source(s):
- Notes:

## lease_expires_at
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## lease_fresh
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## lease_ttl_ms
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## last_heartbeat_ts
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## heartbeat_age_ms
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## last_event_id
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## last_event_ts
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## last_event_kind
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## task_status
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## is_terminal
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## terminal_event_kind
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## terminal_event_ts
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

## terminal_event_id
- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*

- Likely source(s):
- Notes:

