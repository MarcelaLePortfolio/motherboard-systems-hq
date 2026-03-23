/**
 * Phase 103.2 — Invariants
 *
 * Purpose:
 * Establish deterministic read invariants for cognition consumption.
 *
 * Rules:
 * - Pure functions only
 * - No mutation
 * - No reducers
 * - No wiring
 * - No behavior change
 */

import type { CognitionContractEnvelope } from "../gateway";
import { buildOperatorCognitionView } from "../adapter";

export function cognitionReadDeterministic(
  envelope: CognitionContractEnvelope
): boolean {

  const a = buildOperatorCognitionView(envelope);
  const b = buildOperatorCognitionView(envelope);

  return JSON.stringify(a) === JSON.stringify(b);
}

/**
 * Invariant rule:
 * Same input must always produce same cognition read model.
 */
export const COGNITION_READ_INVARIANT =
  "Deterministic cognition reads required.";
