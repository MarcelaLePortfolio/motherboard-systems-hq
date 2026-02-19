/**
 * Phase 44 — Stable reason codes for HTTP mutation-route enforcement.
 *
 * Contract:
 * - Codes are stable identifiers (do not rename once shipped).
 * - New codes may be appended.
 */
export const REASON = Object.freeze({
  // Generic / config
  E_MODE_INVALID: "E_MODE_INVALID",
  E_ALLOWLIST_MISSING: "E_ALLOWLIST_MISSING",

  // Mutation boundary
  E_MUTATION_BLOCKED: "E_MUTATION_BLOCKED",
  E_MUTATION_NOT_ALLOWLISTED: "E_MUTATION_NOT_ALLOWLISTED",

  // Internal errors (should be rare; shadow/enforce behavior still deterministic)
  E_INTERNAL_ERROR: "E_INTERNAL_ERROR",
});
