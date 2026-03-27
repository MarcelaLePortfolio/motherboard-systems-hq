import { evaluateGovernanceSignal } from "../../src/governance/governance_enforcement_evaluator";

function assert(condition: unknown, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

const safe = evaluateGovernanceSignal("safe");
assert(safe.decision === "allow", "Safe severity must allow");
assert(
  safe.operator_authority === "preserved",
  "Operator authority must remain preserved"
);

const warning = evaluateGovernanceSignal("warning");
assert(warning.decision === "warn", "Warning severity must warn");
assert(
  warning.execution_authority === "human_required",
  "Execution authority must remain human-required"
);

const critical = evaluateGovernanceSignal("critical");
assert(critical.decision === "block", "Critical severity must block");
assert(
  critical.system_role === "bounded_enforcement",
  "System role must remain bounded enforcement"
);

console.log("Phase 322 governance enforcement smoke checks passed");
