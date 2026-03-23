/**
 * Phase 102.2 — Guard
 *
 * Purpose:
 * Establish allowed cognition consumption paths and prevent
 * accidental deep imports in future work.
 *
 * Rules:
 * - Documentation-level enforcement only
 * - No runtime logic
 * - No behavior change
 */

export const ALLOWED_COGNITION_IMPORT_PATH =
  "src/cognition/gateway";

/**
 * Architectural rule:
 *
 * Consumers MUST import from:
 * cognition/gateway
 *
 * Consumers MUST NOT import from:
 * cognition/contracts
 * cognition/selectors
 * cognition/operator-read
 * cognition/exposure (directly)
 *
 * Gateway remains the single approved read surface.
 */

export const COGNITION_IMPORT_RULE =
  "Use cognition gateway only.";
