/**
 * Phase 112.1 — Span
 *
 * Purpose:
 * Establish bounded cognition span definition for safe
 * downstream consumption without changing runtime behavior.
 *
 * Rules:
 * - Read-only span definition
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../bridge";
export * from "../link";

export const COGNITION_SPAN_VERSION = "112.1";

export const COGNITION_SPAN_RULE =
  "Cognition span must remain bounded and read-only.";
