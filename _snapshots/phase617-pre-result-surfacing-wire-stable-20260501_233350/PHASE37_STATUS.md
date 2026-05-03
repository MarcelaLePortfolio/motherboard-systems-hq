# Phase 37 — Status Snapshot

Branch: feature/phase37-0-planning
Mode: Planning Only (No Implementation)

## Baseline
Golden tag: v36.4-phase36-run-list-observability (immutable)

## Planning Artifacts Complete
- Phase objective + invariants defined
- run_view column inventory captured
- run_view SQL definition captured (authoritative)
- Provenance matrix template generated
- Acceptance-check SQL (read-only) defined
- Regeneration script added (zsh-safe)
- Planning handoff documented

## Phase 37 Invariant Target
Guarantee run_view is:
1) Explainable (every field SQL-traceable)
2) Temporally coherent (no time travel; canonical ordering)
3) Closed-world (no hidden state / JS inference)

## Next Action (Still Docs-Only)
Fill PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md
in this strict order:

1) last_event_id / last_event_ts / last_event_kind
2) terminal_event_* + is_terminal
3) lease_* + heartbeat_*
4) task_id / actor / task_status

No schema changes.
No view edits.
No endpoint changes.
No worker changes.

## Guardrails
- Single-writer contract remains intact.
- run_view remains read-only projection.
- 3 failed hypotheses in any future implementation => revert to last stable tag.

Phase 37.0 planning is structurally complete.
