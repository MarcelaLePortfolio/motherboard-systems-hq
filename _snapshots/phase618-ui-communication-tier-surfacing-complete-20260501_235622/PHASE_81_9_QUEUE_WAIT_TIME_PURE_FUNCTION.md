PHASE 81.9 — DERIVED TELEMETRY CONTINUATION
Queue Wait Time Pure Function Implementation

Date: 2026-03-17

────────────────────────────────

OBJECTIVE

Implement Queue Wait Time as a pure derived telemetry function.

Scope strictly limited to:

Read timestamps
Compute difference
Return numeric value

No reducer interaction.
No scheduling interaction.
No authority interaction.

────────────────────────────────

PURE FUNCTION CONTRACT

Function behavior:

Input:

task_created_ts
run_started_ts (optional)
now_ts (fallback)

Output:

wait_time_ms

Rules:

If run_started_ts exists:

wait_time_ms =
run_started_ts − task_created_ts

If run not started:

wait_time_ms =
now_ts − task_created_ts

If negative:

Clamp to 0.

Function must be:

Deterministic
Side-effect free
Reducer neutral

────────────────────────────────

REFERENCE IMPLEMENTATION (TYPESCRIPT)

File target:

src/telemetry/derived/queueWaitTime.ts

Implementation:

export function deriveQueueWaitTimeMs(
  taskCreatedTs: number,
  runStartedTs?: number,
  nowTs?: number
): number {

  const referenceTs =
    runStartedTs ??
    nowTs ??
    Date.now();

  const wait =
    referenceTs - taskCreatedTs;

  if (wait < 0) {
    return 0;
  }

  return wait;
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
Returns number

Classification:

SAFE DERIVED TELEMETRY

────────────────────────────────

LOCAL VALIDATION CASES

Case 1:

created 1000
started 2000

Result:

1000

Case 2:

created 1000
not started
now 2500

Result:

1500

Case 3:

created future timestamp

Result:

0 (clamped)

Case 4:

identical timestamps

Result:

0

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

Phase 81.10 — Exposure Safety Review

Goal:

Ensure metric exposure cannot influence automation decisions.

────────────────────────────────

STATUS

Pure function defined.
Implementation bounded.
Ready for safe exposure review.

END PHASE 81.9
