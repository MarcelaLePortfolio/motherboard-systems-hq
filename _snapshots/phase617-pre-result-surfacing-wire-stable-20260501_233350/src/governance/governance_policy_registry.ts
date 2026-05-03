/*
Phase 324 — Governance Policy Registry
Deterministic structured policy definitions
No runtime wiring
No execution mutation
No autonomous authority
*/

import type {
  GovernanceEnforcementDecision,
  GovernanceEnforcementReason
} from "./governance_enforcement_contract"

export type GovernancePolicyDefinition = {
  id: string
  name: string
  description: string
  decision: GovernanceEnforcementDecision
  reason: GovernanceEnforcementReason
  operator_authority: "preserved"
  system_role: "bounded_enforcement"
  execution_authority: "human_required"
}

export const GOVERNANCE_POLICY_REGISTRY: GovernancePolicyDefinition[] = [
  {
    id: "policy-safe-allow",
    name: "Safe Allow Policy",
    description: "Allows execution when no governance violation is detected.",
    decision: "allow",
    reason: "no_violation_detected",
    operator_authority: "preserved",
    system_role: "bounded_enforcement",
    execution_authority: "human_required"
  },
  {
    id: "policy-warning-warn",
    name: "Warning Review Policy",
    description: "Warns when governance caution or operator review is required.",
    decision: "warn",
    reason: "operator_review_required",
    operator_authority: "preserved",
    system_role: "bounded_enforcement",
    execution_authority: "human_required"
  },
  {
    id: "policy-critical-block",
    name: "Critical Block Policy",
    description: "Blocks when critical governance conditions are detected.",
    decision: "block",
    reason: "governance_critical_detected",
    operator_authority: "preserved",
    system_role: "bounded_enforcement",
    execution_authority: "human_required"
  }
]

export function getGovernancePolicyByDecision(
  decision: GovernanceEnforcementDecision
): GovernancePolicyDefinition | undefined {
  return GOVERNANCE_POLICY_REGISTRY.find(
    (policy) => policy.decision === decision
  )
}
