/**
 * Phase 423.3 — Governance Execution Eligibility Snapshot
 *
 * Stable exported helper for execution-layer consumption.
 * Execution must consume this helper only, not governance internals.
 */

import { proveGovernanceAuthorizationGate } from "./prove_governance_authorization_gate";

export interface GovernanceExecutionEligibilitySnapshot {
  readonly authorizationEligible: boolean;
  readonly governanceReason: string | null;
}

export function getGovernanceExecutionEligibilitySnapshot(): GovernanceExecutionEligibilitySnapshot {
  const proof = proveGovernanceAuthorizationGate();

  return Object.freeze({
    authorizationEligible: proof.authorizationEligible,
    governanceReason: proof.authorizationEligible ? null : proof.gateStatus,
  });
}
