STATE NOTE — PHASE 66A TELEMETRY INTEGRITY VERIFICATION PLAN
Telemetry Integrity Verification Corridor
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Verify telemetry correctness in the data layer without changing layout,
metric ownership, or protected UI surface.

This phase is verification-only.

NO layout changes.
NO wrapper additions.
NO ID changes.
NO tile growth.
NO ownership overlap.
NO reducer binding.

────────────────────────────────

WHY THIS PHASE EXISTS

Phase 66 created new telemetry reducers.
Phase 67 verified runtime compatibility and event-shape alignment.
Binding was correctly blocked by ownership protection.

Therefore the safest continuation of Phase 66 is now:

Telemetry integrity verification.

This strengthens trust in the telemetry layer while preserving the
hardened dashboard surface.

────────────────────────────────

STRICT SCOPE

Allowed work:

Event integrity verification
Reducer determinism verification
Duplicate-event handling verification
Terminal-state correctness verification
Replay / audit tooling
Static or script-based telemetry validation

Forbidden work:

UI binding
Metric tile reassignment
Protected file edits
Layout mutation
Shared ownership
Ad-hoc telemetry writes into compact metric tiles

────────────────────────────────

PHASE 66A TARGETS

1 Verify event ordering assumptions
2 Verify duplicate-event tolerance
3 Verify queue-depth reducer determinism
4 Verify failed-task reducer determinism
5 Verify malformed-event tolerance
6 Verify replay stability
7 Document exact telemetry assumptions

────────────────────────────────

VERIFICATION DEFINITIONS

Telemetry is considered CORRECT if:

Reducer output is deterministic across replay
Duplicate events do not corrupt derived counts
Malformed events do not corrupt reducer state
Removal events without active entries do not corrupt reducer state
Failed-task counting remains monotonic and deduplicated
No reducer mutates DOM
No reducer crosses ownership boundaries

────────────────────────────────

QUEUE DEPTH CORRECTNESS RULES

Queue reducer must:

Add only on:
task.created
task.queued

Remove only on:
task.started
task.completed
task.failed
task.cancelled

Queue depth must:

Never go negative
Remain stable across repeated replay
Ignore malformed events safely
Ignore duplicate removals safely

────────────────────────────────

FAILED TASK CORRECTNESS RULES

Failed-task reducer must:

Count task.failed events deterministically
Ignore malformed events safely
Deduplicate repeated failure events
Remain monotonic unless explicit reset is invoked

Failed-task count must:

Be stable across repeated replay
Not increment on non-failed states
Not decrement during normal processing

────────────────────────────────

PHASE 66A IMPLEMENTATION ORDER

Phase 66A.1
Telemetry assumptions checkpoint

Phase 66A.2
Reducer replay harness

Phase 66A.3
Malformed / duplicate event verification

Phase 66A.4
Determinism verification script

Phase 66A.5
Completion checkpoint

Each step must preserve protection corridor.

────────────────────────────────

PROPOSED NEW ASSETS

docs/checkpoints/PHASE66A_TELEMETRY_INTEGRITY_VERIFICATION_PLAN_20260316.md
scripts/_local/phase66a_reducer_replay_check.sh
scripts/_local/phase66a_determinism_check.sh
docs/checkpoints/PHASE66A_COMPLETION_CHECKPOINT_20260316.md

────────────────────────────────

PROTECTION REQUIREMENTS

Before any verification execution:

bash scripts/_local/phase65_pre_commit_protection_gate.sh

After any verification asset creation:

bash scripts/_local/phase65_pre_commit_protection_gate.sh

No protected surface edits permitted.

────────────────────────────────

SUCCESS CONDITIONS

Phase 66A is complete when:

Telemetry assumptions are documented
Replay harness exists
Determinism check exists
Duplicate / malformed behavior is verified
Protection gate remains green
No ownership collision introduced
No UI mutation introduced

────────────────────────────────

NEXT EXECUTION TARGET

Phase 66A.2 — Reducer replay harness.

Verification only.
No UI work.
No binding work.

────────────────────────────────

END PHASE 66A PLAN
