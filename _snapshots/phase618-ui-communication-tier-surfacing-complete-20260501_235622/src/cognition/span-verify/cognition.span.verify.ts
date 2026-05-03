/**
 * Phase 112.2 — Verify
 *
 * Purpose:
 * Prove cognition span remains deterministic through
 * the bounded span surface.
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

export function cognitionSpanDeterministic(
  envelope: CognitionContractEnvelope
): boolean {
  const a = buildCognitionSurface(envelope);
  const b = buildCognitionSurface(envelope);

  return JSON.stringify(a) === JSON.stringify(b);
}

export const COGNITION_SPAN_VERIFY_RULE =
  "Cognition span must remain deterministic.";
