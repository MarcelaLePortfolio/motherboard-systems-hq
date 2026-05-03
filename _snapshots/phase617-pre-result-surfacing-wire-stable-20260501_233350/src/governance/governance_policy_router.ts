/*
Phase 328 — Governance Policy Router

Provides deterministic routing from enforcement decision
to the correct governance policy definition.

Purpose:
Prevent policy drift and ensure enforcement always maps
to a declared governance rule.
*/

import { GovernanceEnforcementDecision } from "./governance_decision_model"
import {
  GOVERNANCE_POLICY_REGISTRY,
  GovernancePolicyDefinition
} from "./governance_policy_registry"

export function routeGovernancePolicy(
  decision: GovernanceEnforcementDecision
): GovernancePolicyDefinition {

  const policy = GOVERNANCE_POLICY_REGISTRY.find(
    (p) => p.decision === decision
  )

  if (!policy) {
    throw new Error(
      "Governance policy routing failure — no matching policy"
    )
  }

  return policy
}
