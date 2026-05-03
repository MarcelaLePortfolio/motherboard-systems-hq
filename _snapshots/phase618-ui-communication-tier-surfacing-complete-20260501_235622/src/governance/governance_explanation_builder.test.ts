import { buildGovernanceResult } from "./governance_enforcement_result"
import { buildGovernanceExplanation } from "./governance_explanation_builder"

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message)
  }
}

const allowResult = buildGovernanceResult(
  "allow",
  "no_violation_detected",
  "policy-safe-allow",
  "No governance violations detected."
)

const allowExplanation = buildGovernanceExplanation(allowResult)

assert(
  allowExplanation.summary === "Governance check passed",
  "Allow explanation summary mismatch"
)

const warnResult = buildGovernanceResult(
  "warn",
  "operator_review_required",
  "policy-warning-warn",
  "Operator review required."
)

const warnExplanation = buildGovernanceExplanation(warnResult)

assert(
  warnExplanation.summary === "Governance review recommended",
  "Warn explanation summary mismatch"
)

const blockResult = buildGovernanceResult(
  "block",
  "governance_critical_detected",
  "policy-critical-block",
  "Critical governance condition detected."
)

const blockExplanation = buildGovernanceExplanation(blockResult)

assert(
  blockExplanation.summary === "Governance protection triggered",
  "Block explanation summary mismatch"
)

console.log("Governance explanation builder deterministic")
