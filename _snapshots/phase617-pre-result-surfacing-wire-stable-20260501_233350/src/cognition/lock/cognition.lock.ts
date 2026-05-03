/**
 * Phase 103.1 — Lock
 *
 * Purpose:
 * Establish the structural lock marker for bounded cognition surfaces.
 *
 * Rules:
 * - No runtime mutation
 * * No reducers
 * - No wiring
 * - No behavior change
 * - Boundary protection only
 */

export const COGNITION_LOCK_VERSION = "103.1";

export const COGNITION_LOCKED_BOUNDARIES = [
  "contracts",
  "invariants",
  "drift",
  "replay",
  "exposure",
  "selectors",
  "operator-read",
  "gateway",
  "guard",
  "adapter"
] as const;

/**
 * Locked cognition sequence:
 * hardening -> exposure -> consumption
 *
 * Future work must preserve this order and may not bypass
 * the bounded surfaces already established.
 */
export const COGNITION_LOCK_RULE =
  "Preserve bounded cognition surfaces.";
