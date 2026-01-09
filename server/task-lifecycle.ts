/**
 * Phase 24 — Step 1
 * Canonical task lifecycle guard
 */

export type TaskState = "created" | "running" | "completed" | "failed";

const ORDER: Record<TaskState, number> = {
  created: 0,
  running: 1,
  completed: 2,
  failed: 2,
};

export function isValidTransition(
  prev: TaskState | null,
  next: TaskState
): boolean {
  if (prev === null) return next === "created";
  if (prev === "completed" || prev === "failed") return false;
  return ORDER[next] >= ORDER[prev];
}

export function isTerminal(state: TaskState): boolean {
  return state === "completed" || state === "failed";
}
