PHASE 62B — NEXT TELEMETRY TARGET SELECTION
Date: 2026-03-16

────────────────────────────────

CURRENT POSITION

Running Tasks telemetry is now:

IMPLEMENTED
LOCALLY VERIFIED
BOUNDED
NON-DISRUPTIVE

Telemetry corridor remains:

OPEN
CONTROLLED
STABLE

No regressions introduced.

────────────────────────────────

NEXT TARGET SELECTION RULE

Next telemetry work must follow the same Phase 62B discipline:

Single derivation surface only
Derived from existing task-events data
No new transport
No layout mutation
No server mutation
No reducer redesign

────────────────────────────────

CANDIDATE NEXT METRICS (same corridor)

Only metrics derivable from existing task-events stream:

• Tasks Completed (terminal success count)
• Tasks Failed (terminal failure count)
• Tasks Cancelled
• Total Tasks Seen
• Last Task Event Timestamp
• Active Agents Count (derived from tasks map)

Preferred next candidate:

Tasks Completed

Reason:

Already partially derived in phase22 bindings.
Lowest implementation risk.
Same Map source.
Same counters surface.
No structural expansion required.

────────────────────────────────

SELECTION

Next bounded telemetry target:

TASKS COMPLETED DERIVATION HARDENING

Goal:

Ensure deterministic counting from terminal events only.

────────────────────────────────

SUCCESS CONDITION

Next telemetry work is clearly selected while maintaining Phase 62B discipline:

one metric
one file
one hypothesis
one verification pass

