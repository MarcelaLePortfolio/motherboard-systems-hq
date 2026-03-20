PHASE 80.3 — QUEUE PRESSURE METRIC

Classification: TELEMETRY ONLY  
Corridor: Phase 62B bounded execution surface  
Authority impact: NONE  
Behavior impact: NONE  

────────────────────────────────

OBJECTIVE

Introduce a derived telemetry metric:

Queue Pressure

Purpose:

Detect early saturation risk  
Provide operator awareness signal  
Remain cognition-only  
Preserve deterministic behavior  

No system behavior may change.

────────────────────────────────

DEFINITION

Queue Pressure = Running Tasks / Max Concurrent Capacity

Where:

Running Tasks = existing tasksRunning metric  
Max Concurrent Capacity = static operator-defined capacity constant

This is:

READ ONLY  
DERIVED  
NON-AUTHORITATIVE  

It must never drive behavior.

────────────────────────────────

IMPLEMENTATION DISCIPLINE

Allowed:

Derived calculation  
Local verification  
Telemetry exposure (later phase)

Forbidden:

Reducer logic changes  
Task lifecycle changes  
Policy changes  
Automation triggers  
Decision logic  
Dashboard mutation (until verified)

This phase = calculation only.

────────────────────────────────

IMPLEMENTATION STRATEGY

Step 1:

Create pure function:

computeQueuePressure(running, capacity)

Rules:

Deterministic  
No side effects  
Safe divide handling  
Returns number between 0–1+

Safety handling:

If capacity = 0:

Return 0
Never throw

────────────────────────────────

REFERENCE IMPLEMENTATION

export function computeQueuePressure(
  running: number,
  capacity: number
): number {

  if (capacity <= 0) {
    return 0
  }

  return running / capacity
}

────────────────────────────────

LOCAL VERIFICATION REQUIREMENTS

Verify:

0 / N = 0  
N / N = 1  
N > capacity = >1  
capacity 0 returns 0  

Example checks:

computeQueuePressure(0,10) → 0  
computeQueuePressure(5,10) → .5  
computeQueuePressure(10,10) → 1  
computeQueuePressure(12,10) → 1.2  
computeQueuePressure(5,0) → 0  

No rounding required.

Metric remains raw.

────────────────────────────────

SAFETY RULES

This metric must NEVER:

Trigger execution  
Trigger automation  
Trigger policy  
Trigger reducer change  
Trigger task priority change  

It is:

Observation only.

────────────────────────────────

PHASE EXIT CRITERIA

Phase completes when:

Function created  
Local checks pass  
No reducer touched  
No dashboard touched  
No SSE touched  

Next phase:

Phase 80.4 — Metric Local Validation Wiring

(not implementation yet)

────────────────────────────────

SYSTEM STATUS

System remains:

Cognition-only  
Human authority  
Telemetry expanding safely  
Behavior unchanged  

END PHASE 80.3
