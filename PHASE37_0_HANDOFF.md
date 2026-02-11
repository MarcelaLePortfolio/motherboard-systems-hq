# Phase 37.0 — Planning Handoff (Docs Only)

## What’s Done (this branch)
Branch: `feature/phase37-0-planning`

Planning artifacts added:
- `PHASE37_0.md` — phase objective + invariants (planning only)
- `PHASE37_RUN_PROJECTION_CONTRACT.md` — contract + **run_view field inventory**
- `PHASE37_RUN_VIEW_DEFINITION.sql` — captured `pg_get_viewdef(public.run_view)`
- `PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md` — per-column provenance template (to fill)
- `PHASE37_ACCEPTANCE_CHECKS.sql` — read-only acceptance-check query templates

Helper script:
- `scripts/phase37_0_capture_run_view_docs.zsh` — regenerates definition + provenance template safely in zsh

## Current Canonical `run_view` Columns (from inventory)
- run_id
- task_id
- actor
- lease_expires_at
- lease_fresh
- lease_ttl_ms
- last_heartbeat_ts
- heartbeat_age_ms
- last_event_id
- last_event_ts
- last_event_kind
- task_status
- is_terminal
- terminal_event_kind
- terminal_event_ts
- terminal_event_id

## Phase 37 Core Objective (Invariant-Level)
Guarantee `run_view` is:
1) **Explainable** (field provenance is explicit and SQL-traceable),
2) **Temporally coherent** (no time travel; deterministic “latest” semantics),
3) **Closed-world** (no hidden state/caches/JS inference).

## Next Planning Step (Still No Implementation)
Fill `PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md` using:
- `PHASE37_RUN_VIEW_DEFINITION.sql` as the authority
- `PHASE37_ACCEPTANCE_CHECKS.sql` as the validation lens

Suggested fill order:
1) last_event_* (id/ts/kind) — defines canonical “latest”
2) terminal_* + is_terminal — terminal semantics
3) lease_* + heartbeat_* — derived-now semantics (define “now” source)
4) task_id/actor/task_status — join + derivation rules

## Protocols
- Golden tags immutable: `v36.4-phase36-run-list-observability` is authoritative.
- Phase 37.0 = docs-only (no schema, no endpoints, no worker changes).
- No scope creep; one hypothesis at a time.
- Later implementation phases: 3 failed attempts per hypothesis => revert to last stable baseline.

