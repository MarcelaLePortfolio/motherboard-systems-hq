import { routeGovernancePolicy } from "./governance_policy_router"

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message)
  }
}

const allowPolicy = routeGovernancePolicy("allow")

assert(
  allowPolicy.id === "policy-safe-allow",
  "Allow policy routing failed"
)

const warnPolicy = routeGovernancePolicy("warn")

assert(
  warnPolicy.id === "policy-warning-warn",
  "Warn policy routing failed"
)

const blockPolicy = routeGovernancePolicy("block")

assert(
  blockPolicy.id === "policy-critical-block",
  "Block policy routing failed"
)

console.log("Governance policy router deterministic")
