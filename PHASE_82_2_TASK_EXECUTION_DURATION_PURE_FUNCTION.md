PHASE 82.2 — DERIVED TELEMETRY CONTINUATION
Task Execution Duration Pure Function Implementation

Date: 2026-03-17

────────────────────────────────

OBJECTIVE

Implement Task Execution Duration as a pure derived telemetry function.

Scope strictly limited to:

Read timestamps
Compute difference
Return numeric value or undefined

No reducer interaction.
No scheduling interaction.
No authority interaction.

────────────────────────────────

PURE FUNCTION CONTRACT

Function behavior:

Input:

run_started_ts
run_completed_ts

Output:

execution_duration_ms | undefined

Rules:

If both timestamps exist:

execution_duration_ms =
run_completed_ts − run_started_ts

If either timestamp missing:

Return undefined.

If negative:

Clamp to 0.

Function must be:

Deterministic
Side-effect free
Reducer neutral

────────────────────────────────

REFERENCE IMPLEMENTATION (TYPESCRIPT)

File target:

src/telemetry/derived/executionDuration.ts

Implementation:

export function deriveExecutionDurationMs(
  runStartedTs?: number,
  runCompletedTs?: number
): number | undefined {

  if (
    runStartedTs === undefined ||
    runCompletedTs === undefined
  ) {
    return undefined;
  }

  const duration =
    runCompletedTs - runStartedTs;

  if (duration < 0) {
    return 0;
  }

  return duration;
}

────────────────────────────────

SAFETY REVIEW

Function does NOT:

Mutate reducer
Change task state
Change scheduling
Trigger automation
Trigger retry logic
Trigger execution

Function ONLY:

Reads timestamps
Returns number or undefined

Classification:

SAFE DERIVED TELEMETRY

────────────────────────────────

LOCAL VALIDATION CASES

Case 1:

started 1000
completed 2000

Result:

1000

Case 2:

started 1000
completed 1000

Result:

0

Case 3:

started 3000
completed 2000

Result:

0 (clamped)

Case 4:

started missing
completed 2000

Result:

undefined

Case 5:

started 1000
completed missing

Result:

undefined

────────────────────────────────

IMPLEMENTATION DISCIPLINE

Must be placed:

Derived telemetry directory only.

Must NOT:

Enter reducers
Enter scheduling code
Enter policy layer

Telemetry only.

────────────────────────────────

NEXT PHASE

Phase 82.3 — Exposure Safety Review

Goal:

Ensure metric exposure cannot influence automation decisions.

────────────────────────────────

STATUS

Pure function defined.
Implementation bounded.
Ready for safe exposure review.

END PHASE 82.2
