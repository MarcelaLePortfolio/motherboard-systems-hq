/**
 * Phase 108.1 — Relay
 *
 * Purpose:
 * Establish bounded cognition relay definition for safe
 * downstream consumption without changing runtime behavior.
 *
 * Rules:
 * - Read-only relay definition
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../dispatch";
export * from "../route";

export const COGNITION_RELAY_VERSION = "108.1";

export const COGNITION_RELAY_RULE =
  "Cognition relay must remain bounded and read-only.";
