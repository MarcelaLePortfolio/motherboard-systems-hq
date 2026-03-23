/**
 * Phase 106.1 — Route
 *
 * Purpose:
 * Establish bounded cognition routing surface for safe downstream
 * consumers without changing runtime behavior.
 *
 * Rules:
 * - Read-only routing definition
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../hook";
export * from "../surface";

export const COGNITION_ROUTE_VERSION = "106.1";

export const COGNITION_ROUTE_RULE =
  "Cognition routing must remain bounded and read-only.";
