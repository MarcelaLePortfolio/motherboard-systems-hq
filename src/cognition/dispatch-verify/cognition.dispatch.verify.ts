/**
 * Phase 107.2 — Verify
 *
 * Purpose:
 * Prove cognition dispatch remains deterministic through
 * the bounded dispatch surface.
 *
 * Rules:
 * - Pure verification only
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 */

import type { CognitionContractEnvelope } from "../entry";
import { buildCognitionSurface } from "../surface";

export function cognitionDispatchDeterministic(
  envelope: CognitionContractEnvelope
): boolean {
  const a = buildCognitionSurface(envelope);
  const b = buildCognitionSurface(envelope);

  return JSON.stringify(a) === JSON.stringify(b);
}

export const COGNITION_DISPATCH_VERIFY_RULE =
  "Cognition dispatch must remain deterministic.";
