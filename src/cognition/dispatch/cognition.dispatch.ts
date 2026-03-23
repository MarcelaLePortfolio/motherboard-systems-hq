/**
 * Phase 107.1 — Dispatch
 *
 * Purpose:
 * Establish bounded cognition dispatch definition for safe
 * downstream consumption without changing runtime behavior.
 *
 * Rules:
 * - Read-only dispatch definition
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../route";
export * from "../hook";

export const COGNITION_DISPATCH_VERSION = "107.1";

export const COGNITION_DISPATCH_RULE =
  "Cognition dispatch must remain bounded and read-only.";
