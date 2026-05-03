/**
 * Phase 102.3 — Adapter
 *
 * Purpose:
 * Provide a clean operator-facing cognition consumption adapter
 * sourced strictly from the gateway.
 *
 * Rules:
 * - Gateway imports only
 * - Read-only projection
 * - No runtime mutation
 * - No reducers
 * - No behavior change
 */

import type { CognitionContractEnvelope } from "../gateway";
import { buildOperatorCognitionReadModel } from "../operator-read";

export function buildOperatorCognitionView(
  envelope: CognitionContractEnvelope
) {
  return buildOperatorCognitionReadModel(envelope);
}

/**
 * Adapter marker for future dashboard/operator wiring.
 */
export const COGNITION_ADAPTER_VERSION = "102.3";
