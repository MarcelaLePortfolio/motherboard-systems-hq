/**
 * Phase 111.1 — Bridge
 *
 * Purpose:
 * Establish bounded cognition bridge definition for safe
 * downstream consumption without changing runtime behavior.
 *
 * Rules:
 * - Read-only bridge definition
 * - No reducers
 * * No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../link";
export * from "../channel";

export const COGNITION_BRIDGE_VERSION = "111.1";

export const COGNITION_BRIDGE_RULE =
  "Cognition bridge must remain bounded and read-only.";
