/**
 * Phase 102.1 — Gateway
 *
 * Purpose:
 * Establish the single approved cognition import boundary for
 * downstream read consumers.
 *
 * Rules:
 * - Read-only import boundary
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

export * from "../exposure";

/**
 * Phase 102 gateway marker.
 * Downstream consumers should import cognition reads from this module
 * instead of deeper cognition layer paths.
 */
export const COGNITION_GATEWAY_VERSION = "102.1";
