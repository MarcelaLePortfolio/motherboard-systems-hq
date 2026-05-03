/**
 * Phase 101.1 — Cognition Export Surface
 *
 * Purpose:
 * Establish the official read boundary for cognition layer outputs.
 *
 * Rules:
 * - Read exposure only
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../contracts";
export * from "../invariants";
export * from "../drift";
export * from "../replay";

/**
 * Phase 101 export boundary marker.
 * Used to prevent unauthorized direct imports from deeper cognition layers.
 */
export const COGNITION_EXPOSURE_VERSION = "101.1";
