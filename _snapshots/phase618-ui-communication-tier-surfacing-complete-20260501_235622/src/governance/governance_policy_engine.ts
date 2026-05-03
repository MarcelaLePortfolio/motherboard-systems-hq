/*
Phase 323 — Governance Policy Engine Foundation
Deterministic policy evaluation layer
No runtime wiring
No execution mutation
No autonomous authority
*/

import {
  GovernanceEnforcementResult,
  buildGovernanceEnforcementResult
} from "./governance_enforcement_contract"

export type GovernancePolicyInput = {
  has_warning: boolean
  has_critical: boolean
  operator_review_required: boolean
}

export function evaluateGovernancePolicy(
  input: GovernancePolicyInput
): GovernanceEnforcementResult {

  if (input.has_critical) {
    return buildGovernanceEnforcementResult(
      "block",
      "governance_critical_detected"
    )
  }

  if (input.operator_review_required || input.has_warning) {
    return buildGovernanceEnforcementResult(
      "warn",
      "operator_review_required"
    )
  }

  return buildGovernanceEnforcementResult(
    "allow",
    "no_violation_detected"
  )
}
