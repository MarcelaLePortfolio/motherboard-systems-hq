/**
 * Task Contract (Phase 14)
 * Canonical statuses:
 * queued | delegated | running | blocked | complete | canceled | failed
 *
 * NOTE:
 * - UI "Complete" should always transition to canonical "complete".
 * - Backend validators should accept legacy spellings only if they exist in stored data.
 */

export const TASK_STATUSES = Object.freeze([
  "queued",
  "delegated",
  "running",
  "blocked",
  "complete",
  "canceled",
  "failed",
]);

// Allowed next states from each state.
// (Keep this permissive enough for UI + operator actions, but still deterministic.)
export const TASK_ALLOWED_TRANSITIONS = Object.freeze({
  queued: ["delegated", "canceled", "failed"],
  delegated: ["running", "blocked", "complete", "canceled", "failed"],
  running: ["blocked", "complete", "canceled", "failed"],
  blocked: ["running", "complete", "canceled", "failed"],
  complete: [],
  canceled: [],
  failed: [],
});

export function assertValidTaskStatus(status) {
  if (!TASK_STATUSES.includes(status)) {
    throw new Error(`Invalid task status: ${status}`);
  }
  return true;
}

export function assertValidTransition(prevStatus, nextStatus) {
  assertValidTaskStatus(prevStatus);
  assertValidTaskStatus(nextStatus);

  const allowed = TASK_ALLOWED_TRANSITIONS[prevStatus] || [];
  if (!allowed.includes(nextStatus)) {
    throw new Error(`Invalid transition: ${prevStatus} → ${nextStatus}`);
  }
  return true;
}
