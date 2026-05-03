import { buildGovernanceResult } from "./governance_enforcement_result"
import { buildGovernanceAuditRecord } from "./governance_audit_log"

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message)
  }
}

const result = buildGovernanceResult(
  "warn",
  "operator_review_required",
  "policy-warning-warn",
  "Operator review required."
)

const record = buildGovernanceAuditRecord(result)

assert(
  record.policy_id === "policy-warning-warn",
  "Policy id mismatch"
)

assert(
  record.decision === "warn",
  "Decision mismatch"
)

assert(
  record.operator_authority === "preserved",
  "Authority invariant violated"
)

console.log("Governance audit log deterministic")
