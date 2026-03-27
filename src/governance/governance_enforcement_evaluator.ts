/*
Phase 322 — Governance Enforcement Evaluator
Deterministic policy evaluation layer
No runtime wiring
No execution authority
Cognition-only enforcement classification
*/

import {
  GovernanceEnforcementResult,
  buildGovernanceEnforcementResult
} from "./governance_enforcement_contract"

export type GovernanceSignalSeverity =
  | "safe"
  | "warning"
  | "critical"

export function evaluateGovernanceSignal(
  severity: GovernanceSignalSeverity
): GovernanceEnforcementResult {

  if (severity === "safe") {
    return buildGovernanceEnforcementResult(
      "allow",
      "no_violation_detected"
    )
  }

  if (severity === "warning") {
    return buildGovernanceEnforcementResult(
      "warn",
      "governance_warning_detected"
    )
  }

  return buildGovernanceEnforcementResult(
    "block",
    "governance_critical_detected"
  )
}
