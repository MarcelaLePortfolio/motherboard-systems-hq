PHASE 62B — NEXT METRIC SELECTION
Date: 2026-03-16

────────────────────────────────

CURRENT POSITION

Phase 62B telemetry corridor now contains:

Running Tasks — COMPLETE pattern
Tasks Completed — COMPLETE pattern
Tasks Failed — COMPLETE pattern

Terminal lifecycle telemetry base is now established.

────────────────────────────────

REMAINING SAFE CANDIDATES

Remaining metrics derivable from existing task-events surface:

• Total Tasks Seen
• Last Task Event Timestamp
• Active Agents Count

────────────────────────────────

RISK ORDERING

Lowest risk next metric:

TOTAL TASKS SEEN

Reason:

Pure identity counting.
No terminal interpretation logic.
No state transitions required.
Uses existing task Map.
No new Sets required.
No ambiguity under replay.

Derivation rule:

Total Tasks Seen =
unique task_id count observed.

────────────────────────────────

SELECTION

Next bounded telemetry target:

TOTAL TASKS SEEN DERIVATION HARDENING

Goal:

Ensure deterministic counting of unique task identities only.

Allowed signals:

task.created
task.started
task.completed
task.failed
task.cancelled

Rules:

Each task_id counts once.
Duplicate events must not increase count.
Out-of-order events must not increase count.
Unknown events ignored.

────────────────────────────────

SUCCESS CONDITION

Next telemetry work remains inside Phase 62B discipline:

one metric
one file
one hypothesis
one verification pass

