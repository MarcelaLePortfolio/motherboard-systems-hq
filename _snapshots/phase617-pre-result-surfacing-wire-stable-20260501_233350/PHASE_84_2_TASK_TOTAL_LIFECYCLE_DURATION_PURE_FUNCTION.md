PHASE 84.2 — DERIVED TELEMETRY CONTINUATION
Task Total Lifecycle Duration Pure Function Specification

Date: 2026-03-17

OBJECTIVE

Define deterministic calculation rules for task_total_lifecycle_duration_ms.

Specification only.
No runtime wiring.

PURE FUNCTION DEFINITION

Function name:

deriveTaskTotalLifecycleDurationMs

Inputs:

task_created_ts
run_completed_ts

Output:

Integer ≥ 0
OR
undefined

Function definition:

If either timestamp missing:

return undefined

Else:

duration = run_completed_ts − task_created_ts

If duration < 0:

return 0

Else:

return duration

DETERMINISM REQUIREMENTS

Function must be:

Pure
Deterministic
Idempotent
Side-effect free

Function must NOT:

Call system clock
Call randomness
Call external services
Read mutable state
Write any state

Input → Output only.

EDGE CASE HANDLING

Case 1:

created 1000
completed 3000

Result:

2000

Case 2:

created 5000
completed 5000

Result:

0

Case 3:

created 9000
completed 8000

Result:

0 (clamped)

Case 4:

created missing

Result:

undefined

Case 5:

completed missing

Result:

undefined

IMPLEMENTATION DISCIPLINE

Function location:

derived_telemetry/

Must NOT be placed in:

Reducers
Scheduler
Automation engine
Policy layer
Execution lifecycle engine

Telemetry boundary only.

CORRIDOR COMPLIANCE

Specification only.
No runtime mutation.
No authority expansion.
No automation expansion.
No reducer mutation.

Phase 62B corridor preserved.

NEXT PHASE

Phase 84.3 — Exposure Safety Review

STATUS

Pure function specified.
Deterministic behavior defined.

END PHASE 84.2
