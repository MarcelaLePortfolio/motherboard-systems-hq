/**
 * Phase 105.1 — Hook
 *
 * Purpose:
 * Establish the bounded cognition enablement hook for downstream
 * system consumers without changing runtime behavior.
 *
 * Rules:
 * - Read-only hook only
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../entry";
export * from "../surface";
export * from "../proof";

export const COGNITION_HOOK_VERSION = "105.1";

export const COGNITION_HOOK_RULE =
  "Use cognition hook for bounded enablement reads.";
