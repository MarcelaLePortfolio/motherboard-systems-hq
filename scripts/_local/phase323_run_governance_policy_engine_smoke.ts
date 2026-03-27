import { evaluateGovernancePolicy } from "../../src/governance/governance_policy_engine";

function assert(condition: unknown, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

const safe = evaluateGovernancePolicy({
  has_warning: false,
  has_critical: false,
  operator_review_required: false
});
assert(safe.decision === "allow", "Safe policy must allow");
assert(
  safe.operator_authority === "preserved",
  "Operator authority must remain preserved"
);

const warning = evaluateGovernancePolicy({
  has_warning: true,
  has_critical: false,
  operator_review_required: false
});
assert(warning.decision === "warn", "Warning policy must warn");
assert(
  warning.execution_authority === "human_required",
  "Execution authority must remain human-required"
);

const critical = evaluateGovernancePolicy({
  has_warning: false,
  has_critical: true,
  operator_review_required: false
});
assert(critical.decision === "block", "Critical policy must block");
assert(
  critical.system_role === "bounded_enforcement",
  "System role must remain bounded enforcement"
);

const review = evaluateGovernancePolicy({
  has_warning: false,
  has_critical: false,
  operator_review_required: true
});
assert(review.decision === "warn", "Operator review requirement must warn");

console.log("Phase 323 governance policy engine smoke checks passed");
