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
  // { method: "POST", path: "/api/tasks" },
]);
