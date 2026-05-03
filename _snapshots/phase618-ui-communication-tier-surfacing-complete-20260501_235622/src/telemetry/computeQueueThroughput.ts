/*
Phase 81.2 — Queue Throughput Pure Function Implementation
Classification: Derived telemetry only
Behavior impact: NONE
Authority impact: NONE

Queue Throughput Rate = Tasks Completed / Time Window Minutes

Safety rules:

Pure function
No side effects
No reducer interaction
No policy interaction
No automation interaction
*/

export function computeQueueThroughput(
  completedTasks: number,
  windowMinutes: number
): number {
  if (windowMinutes <= 0) {
    return 0
  }

  if (completedTasks <= 0) {
    return 0
  }

  return completedTasks / windowMinutes
}
