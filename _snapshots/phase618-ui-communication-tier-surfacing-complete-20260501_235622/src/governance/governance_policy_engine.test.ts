/*
Phase 323 — Governance Policy Engine Determinism Test
Ensures policy evaluation remains stable
No runtime wiring
*/

import { evaluateGovernancePolicy } from "./governance_policy_engine"

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message)
  }
}

const safe = evaluateGovernancePolicy({
  has_warning: false,
  has_critical: false,
  operator_review_required: false
})

assert(safe.decision === "allow", "Safe policy must allow")

const warn = evaluateGovernancePolicy({
  has_warning: true,
  has_critical: false,
  operator_review_required: false
})

assert(warn.decision === "warn", "Warning policy must warn")

const critical = evaluateGovernancePolicy({
  has_warning: false,
  has_critical: true,
  operator_review_required: false
})

assert(critical.decision === "block", "Critical policy must block")

console.log("Governance policy engine deterministic")
