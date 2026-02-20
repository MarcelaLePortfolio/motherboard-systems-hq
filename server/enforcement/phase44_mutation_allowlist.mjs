/**
 * Phase 44 — HTTP mutation allowlist (server boundary only).
 *
 * Add entries ONLY for routes that are intended to mutate server state.
 * Patterns support Express-style params, e.g.:
 *   { method: "POST", path: "/api/tasks" }
 *   { method: "POST", path: "/api/tasks/:task_id/cancel" }
 *
 * Notes:
 * - Matching is against req.path (no querystring).
 * - Method must be one of: POST, PUT, PATCH, DELETE
 */
export const MUTATION_ALLOWLIST = Object.freeze([
  { method: "POST", path: "/api/phase16-beacon" },
  { method: "POST", path: "/api/tasks-mutations/delegate-taskspec" },
  { method: "POST", path: "/api/dev/emit-reflection" },
  { method: "POST", path: "/api/dev/emit-ops" },
  { method: "POST", path: "/api/delegate-task" },
  { method: "POST", path: "/api/complete-task" },
  { method: "POST", path: "/api/ops/heartbeat" },
  { method: "POST", path: "/api/ops/agent-status" },
  { method: "POST", path: "/api/reflections/signal" },
]);
