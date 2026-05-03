PHASE 83.2 — DERIVED TELEMETRY CONTINUATION
Task Queue Wait Duration Pure Function Specification

Date: 2026-03-17

────────────────────────────────

OBJECTIVE

Define deterministic calculation rules for task_queue_wait_duration_ms.

Purpose:

Ensure pure calculation behavior.
Guarantee deterministic results.
Maintain telemetry corridor discipline.

Specification only.

No runtime wiring.

────────────────────────────────

PURE FUNCTION DEFINITION

Function name:

deriveTaskQueueWaitDurationMs

Inputs:

task_created_ts
run_started_ts

Output:

Integer ≥ 0
OR
undefined

Function definition:

If either timestamp missing:

return undefined

Else:

duration = run_started_ts − task_created_ts

If duration < 0:

return 0

Else:

return duration

────────────────────────────────

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

────────────────────────────────

EDGE CASE HANDLING

Case 1:

created 1000
started 2000

Result:

1000

Case 2:

created 5000
started 5000

Result:

0

Case 3:

created 9000
started 8000

Result:

0 (clamped)

Case 4:

created missing

Result:

undefined

Case 5:

started missing

Result:

undefined

────────────────────────────────

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

────────────────────────────────

CORRIDOR COMPLIANCE

This phase obeys:

Specification only
No runtime mutation
No authority expansion
No automation expansion
No reducer mutation

Phase 62B corridor preserved.

────────────────────────────────

NEXT PHASE

Phase 83.3 — Exposure Safety Review

Goal:

Ensure queue wait metric cannot influence automation.

────────────────────────────────

STATUS

Pure function specified.
Deterministic behavior defined.
Ready for exposure safety review.

END PHASE 83.2
