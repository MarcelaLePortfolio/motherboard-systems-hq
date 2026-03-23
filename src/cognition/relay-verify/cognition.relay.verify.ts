/**
 * Phase 108.2 — Verify
 *
 * Purpose:
 * Prove cognition relay remains deterministic through
 * the bounded relay surface.
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

export function cognitionRelayDeterministic(
  envelope: CognitionContractEnvelope
): boolean {
  const a = buildCognitionSurface(envelope);
  const b = buildCognitionSurface(envelope);

  return JSON.stringify(a) === JSON.stringify(b);
}

export const COGNITION_RELAY_VERIFY_RULE =
  "Cognition relay must remain deterministic.";
