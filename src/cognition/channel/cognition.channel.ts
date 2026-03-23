/**
 * Phase 109.1 — Channel
 *
 * Purpose:
 * Establish bounded cognition channel definition for safe
 * communication pathways without changing runtime behavior.
 *
 * Rules:
 * - Read-only channel definition
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../relay";
export * from "../dispatch";

export const COGNITION_CHANNEL_VERSION = "109.1";

export const COGNITION_CHANNEL_RULE =
  "Cognition channels must remain bounded and read-only.";
