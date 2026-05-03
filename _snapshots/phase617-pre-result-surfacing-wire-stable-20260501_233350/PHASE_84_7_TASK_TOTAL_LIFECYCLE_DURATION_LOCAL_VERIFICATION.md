PHASE 84.7 — DERIVED TELEMETRY CONTINUATION
Task Total Lifecycle Duration Local Verification Plan

Date: 2026-03-17

OBJECTIVE

Define safe local verification procedure before dashboard exposure.

Verification must confirm:

Determinism
Null safety
Missing timestamp handling
No runtime coupling

VERIFICATION TARGET

Function:

task_total_lifecycle_duration_ms

Inputs:

created_at
completed_at

Expected behavior:

If both exist:

completed_at - created_at

If either missing:

undefined

LOCAL TEST STRATEGY

Verification must run:

Locally only.
Test harness only.

Must NOT run:

Runtime paths
Worker execution
Reducers
Scheduler
Automation engine

TEST CASE MATRIX

Case 1:
created present
completed present
Result:
positive duration

Case 2:
created present
completed earlier (invalid ordering)
Result:
0 (clamped)

Case 3:
created missing
completed present
Result:
undefined

Case 4:
created present
completed missing
Result:
undefined

Case 5:
both missing
Result:
undefined

DETERMINISM RULE

Multiple executions must produce:

Identical outputs.

Must NOT use:

Date.now()
performance.now()
External services
Runtime clocks

Only stored timestamps allowed.

IMPLEMENTATION LOCATION

derived_telemetry/tests/

File example:

task_total_lifecycle_duration.test.ts

Must remain:

Test-only scope.

CORRIDOR COMPLIANCE

Verification only.
No behavior changes.
No authority changes.
No automation expansion.
No reducer mutation.

Phase 62B corridor preserved.

STATUS

Local verification defined.
Ready for implementation phase.

NEXT PHASE

Phase 84.8 — Verification Implementation

END PHASE 84.7
