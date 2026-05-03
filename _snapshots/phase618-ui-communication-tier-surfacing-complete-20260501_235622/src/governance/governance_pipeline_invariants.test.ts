import { validateGovernanceInvariants } from "./governance_pipeline_invariants"

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message)
  }
}

const valid = validateGovernanceInvariants()

assert(
  valid === true,
  "Governance invariants validation failed"
)

console.log("Governance invariants deterministic")
