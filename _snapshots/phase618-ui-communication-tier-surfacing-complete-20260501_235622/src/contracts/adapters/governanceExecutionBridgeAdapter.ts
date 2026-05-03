/**
 * Phase 466.2 — Bridge Adapter (STRUCTURAL ONLY)
 *
 * Purpose:
 * Map existing owner outputs → GovernanceExecutionBridgeContract shape
 *
 * Constraints:
 * - NO runtime wiring
 * - NO side effects
 * - NO execution triggering
 * - PURE mapping only
 */

import type {
  GovernanceExecutionBridgeContract,
  NormalizedTaskEnvelope,
  GovernanceEvaluationEnvelope,
  PreparationEnvelope
} from "../governanceExecutionBridgeContract";

export function buildBridgeContract(params: {
  task: NormalizedTaskEnvelope;
  governance: GovernanceEvaluationEnvelope;
  preparation?: Partial<PreparationEnvelope>;
}): GovernanceExecutionBridgeContract {

  return {
    intake: {
      task: params.task
    },
    governance: params.governance,
    preparation: {
      accepted: params.preparation?.accepted ?? false,
      ctx_updates: {
        operatorMode: params.preparation?.ctx_updates?.operatorMode,
        intent: params.preparation?.ctx_updates?.intent
      },
      emitted_events: params.preparation?.emitted_events ?? []
    }
  };
}
