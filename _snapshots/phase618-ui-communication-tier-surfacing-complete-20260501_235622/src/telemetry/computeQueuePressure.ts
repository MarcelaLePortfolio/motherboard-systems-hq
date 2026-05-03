/*
Phase 80.3 — Queue Pressure Metric
Classification: Derived telemetry only
Behavior impact: NONE
Authority impact: NONE

Queue Pressure = Running Tasks / Max Concurrent Capacity

Safety rules:

Pure function
No side effects
No reducer interaction
No policy interaction
No automation interaction
*/

export function computeQueuePressure(
  running: number,
  capacity: number
): number {

  if (capacity <= 0) {
    return 0
  }

  if (running <= 0) {
    return 0
  }

  return running / capacity
}
