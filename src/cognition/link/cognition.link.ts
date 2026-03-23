/**
 * Phase 110.1 — Link
 *
 * Purpose:
 * Establish bounded cognition link definition for safe
 * downstream consumption without changing runtime behavior.
 *
 * Rules:
 * - Read-only link definition
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../channel";
export * from "../relay";

export const COGNITION_LINK_VERSION = "110.1";

export const COGNITION_LINK_RULE =
  "Cognition link must remain bounded and read-only.";
