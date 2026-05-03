import { runGovernancePipeline } from "./governance_decision_pipeline"

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message)
  }
}

const allow = runGovernancePipeline("allow")

assert(
  allow.policy_id === "policy-safe-allow",
  "Allow pipeline routing failed"
)

assert(
  allow.explanation_summary === "Governance check passed",
  "Allow explanation mismatch"
)

const warn = runGovernancePipeline("warn")

assert(
  warn.policy_id === "policy-warning-warn",
  "Warn pipeline routing failed"
)

const block = runGovernancePipeline("block")

assert(
  block.policy_id === "policy-critical-block",
  "Block pipeline routing failed"
)

console.log("Governance decision pipeline deterministic")
