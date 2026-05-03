PHASE 85.1 — TREND INDICATORS

Purpose:

Improve operator cognition by showing whether signals are improving,
degrading, or stable over time.

Display enhancement only.

No reducers modified.
No telemetry changes.
No runtime coupling.
No authority expansion.

System remains cognition-only.

────────────────────────────────

PROBLEM

Current dashboard shows current state only.

Operator must mentally infer:

Is this getting better?
Is this getting worse?
Did this just change?

This increases cognitive load.

Trend hints reduce scan effort.

────────────────────────────────

SOLUTION

Add simple trend classification:

IMPROVING
DEGRADING
STABLE
UNKNOWN

Derived from recent signal history.

Display only.
No decision impact.

────────────────────────────────

TREND MODEL

Trend determined from last known state transitions.

Example model:

GREEN → GREEN = STABLE
YELLOW → GREEN = IMPROVING
GREEN → YELLOW = DEGRADING
RED → YELLOW = IMPROVING
YELLOW → RED = DEGRADING

If insufficient history:

UNKNOWN

────────────────────────────────

DISPLAY RULES

Trend must be:

Subtle
Secondary to status color
Non-distracting
Fast to interpret

Possible representations:

Arrow up (improving)
Arrow down (degrading)
Flat line (stable)
Dot (unknown)

Must not override primary status color.

────────────────────────────────

SAFETY CONSTRAINTS

Trend indicators must:

Never trigger automation
Never change status values
Never affect reducers
Never affect tasks
Never affect agents

Pure cognition assist.

────────────────────────────────

IMPLEMENTATION APPROACH (FUTURE)

Trend computed from:

Recent signal history buffer
Status transition comparison
Lightweight classification

No persistence required initially.

Display derivation acceptable.

────────────────────────────────

SUCCESS CONDITIONS

Operator can instantly see:

What changed
Which direction signals are moving
Which signals are stable

Operator cognitive load reduced.

────────────────────────────────

PHASE RESULT

Operator awareness improved.
Signal interpretation speed improved.
Dashboard cognition layer strengthened.

System remains:

SAFE
READ-ONLY
DETERMINISTIC

END PHASE 85.1

