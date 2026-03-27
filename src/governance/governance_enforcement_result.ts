/*
Phase 325 — Governance Enforcement Result Contract

Defines the deterministic output contract for governance enforcement.

This prevents enforcement drift and ensures all governance checks
return structured, explainable results.
*/

import {
  GovernanceEnforcementDecision,
  GovernanceEnforcementReason
} from "./governance_decision_model"

export interface GovernanceEnforcementResult {

  decision: GovernanceEnforcementDecision

  reason: GovernanceEnforcementReason

  policy_id: string

  explanation: string

  operator_authority: "preserved"

  system_role: "bounded_enforcement"

  execution_authority: "human_required"

  ts: number
}

export function buildGovernanceResult(
  decision: GovernanceEnforcementDecision,
  reason: GovernanceEnforcementReason,
  policy_id: string,
  explanation: string
): GovernanceEnforcementResult {

  return {

    decision,

    reason,

    policy_id,

    explanation,

    operator_authority: "preserved",

    system_role: "bounded_enforcement",

    execution_authority: "human_required",

    ts: Date.now()

  }

}
