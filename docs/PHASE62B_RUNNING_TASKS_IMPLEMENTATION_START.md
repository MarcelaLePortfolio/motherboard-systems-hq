PHASE 62B — RUNNING TASKS IMPLEMENTATION START
Date: 2026-03-16

────────────────────────────────

IMPLEMENTATION TARGET

Begin the narrow implementation of Running Tasks hydration using existing telemetry wiring.

This marks transition from planning → controlled execution.

Scope remains strictly telemetry derivation.

────────────────────────────────

EXECUTION STRATEGY

Implementation must follow smallest-surface approach:

STEP 1 — Locate ingestion point
Identify where /events/task-events stream is normalized.

STEP 2 — Locate telemetry derivation layer
Find where metrics are derived from normalized events.

STEP 3 — Add isolated runningTasks derivation
Do NOT modify existing logic.
Add separate deterministic tracker.

STEP 4 — Bind metric
Only bind if tile already exists.
Do NOT create tile.

STEP 5 — Validate
Replay safety
Drift safety
Layout safety

────────────────────────────────

IMPLEMENTATION PATTERN (REQUIRED)

Pattern must be:

Pure derivation
Pure function if possible
No side effects
No shared mutation outside scope

Preferred structure example:

createRunningTaskTracker()

internal state:

activeTaskIds = Set()
terminalTaskIds = Set()

event handler:

handleTaskEvent(event)

returns:

currentRunningCount

No external coupling beyond telemetry layer.

────────────────────────────────

STRICT NON-INTERFERENCE RULE

This work must NOT modify:

task reducer
event normalization
SSE wiring
UI layout contracts
database schema
policy layer
operator logic

Only telemetry derivation layer may change.

If touching anything else:

STOP
REVERT
REDUCE SURFACE

────────────────────────────────

CODE SHAPE RULES

Implementation must be:

Small
Isolated
Deterministic
Replay-safe
Testable independently

Avoid:

large diffs
cross-file refactors
shared reducer edits
naming churn

If change exceeds narrow telemetry scope:
STOP.

────────────────────────────────

EXPECTED FIRST COMMIT SHAPE

First implementation commit should ideally only:

Add tracker module
Wire into telemetry derivation
Add minimal tests

NOT:

cleanup
renames
formatting passes
secondary metrics

One hypothesis only.

────────────────────────────────

PRE-IMPLEMENTATION SAFETY CHECK

Before touching code verify:

git status clean
Layout contract passing
Replay tests passing
Drift tests passing

This confirms safe baseline.

────────────────────────────────

ROLLBACK ANCHOR

If instability appears:

git log --oneline

Identify last stable commit.

git revert OR hard reset per Marcela protocol.

Never stabilize forward.

────────────────────────────────

SUCCESS MARKER FOR THIS STEP

Running Tasks metric derivation exists but may not yet be visible.

Goal of this step is safe derivation introduction only.

Visibility binding may follow as separate commit.

System must remain:

Stable
Protected
Replay-safe
Drift-safe
Behaviorally identical

Telemetry corridor progresses without risk expansion.

