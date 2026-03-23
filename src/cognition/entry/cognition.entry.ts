/**
 * Phase 104.1 — Entry
 *
 * Purpose:
 * Establish the official system entry point for bounded cognition
 * integration without changing runtime behavior.
 *
 * Rules:
 * - Read-only entry registration
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../gateway";
export * from "../adapter";
export * from "../lock";
export * from "../invariants-read";

/**
 * Phase 104 entry marker.
 * Downstream system integrations should begin from this module.
 */
export const COGNITION_ENTRY_VERSION = "104.1";

/**
 * Approved cognition integration path.
 */
export const COGNITION_ENTRY_RULE =
  "Use cognition entry for bounded system integration.";
