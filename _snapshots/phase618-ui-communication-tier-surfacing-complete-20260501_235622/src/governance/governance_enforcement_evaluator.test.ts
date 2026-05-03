/*
Phase 322 — Governance Enforcement Determinism Test
Ensures enforcement decisions remain stable
No runtime influence
*/

import { evaluateGovernanceSignal } from "./governance_enforcement_evaluator"

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message)
  }
}

const safe = evaluateGovernanceSignal("safe")

assert(safe.decision === "allow", "Safe should allow")
assert(safe.operator_authority === "preserved", "Authority must remain human")

const warn = evaluateGovernanceSignal("warning")

assert(warn.decision === "warn", "Warning should warn")

const critical = evaluateGovernanceSignal("critical")

assert(critical.decision === "block", "Critical should block")

console.log("Governance enforcement evaluator deterministic")
