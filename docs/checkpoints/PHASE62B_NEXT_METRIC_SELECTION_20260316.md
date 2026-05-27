PHASE 62B — NEXT METRIC SELECTION
Date: 2026-03-16

────────────────────────────────

CURRENT POSITION

Phase 62B telemetry corridor now contains:

Running Tasks — COMPLETE pattern
Tasks Completed — COMPLETE pattern

Both metrics now satisfy:

IMPLEMENTED
LOCALLY VERIFIED
CORRIDOR SAFE
NON-ESCALATED

Process pattern is now proven repeatable.

────────────────────────────────

REMAINING SAFE CANDIDATES

Remaining metrics derivable from existing task-events surface:

• Tasks Failed
• Tasks Cancelled
• Total Tasks Seen
• Last Task Event Timestamp
• Active Agents Count

────────────────────────────────

RISK ORDERING

Lowest risk next metric:

TASKS FAILED

Reason:

Already implicitly derived from terminal events.
Uses same Set-based identity pattern.
Same Map surface.
No new data model required.
No new UI surface required.
No event interpretation ambiguity.

This maintains pattern symmetry:

Running → active set
Completed → success set
Failed → failure set

────────────────────────────────

SELECTION

Next bounded telemetry target:

TASKS FAILED DERIVATION HARDENING

Goal:

Ensure deterministic counting from terminal failure events only.

Allowed source signals:

task.failed
task.cancelled
task.canceled
status failed
status error

Must not increment from:

task.completed
queued
started
running

────────────────────────────────

SUCCESS CONDITION

Next telemetry work remains inside Phase 62B discipline:

one metric
one file
one hypothesis
one verification pass

