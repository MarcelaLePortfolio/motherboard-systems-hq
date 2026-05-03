/*
Phase 298 — Governance Advisory Operator View Model
Pure operator cognition shaping layer
No enforcement
No routing
No mutation
*/

import {
  GovernanceDigest
} from "./governance_advisory_digest"

export type GovernanceOperatorView = {
  status: "healthy" | "attention" | "critical"
  headline: string
}

export function buildGovernanceOperatorView(
  digest: GovernanceDigest
): GovernanceOperatorView {

  if (digest.highest_severity === "critical") {

    return {
      status: "critical",
      headline: "Critical governance signals require operator review"
    }

  }

  if (digest.highest_severity === "risk") {

    return {
      status: "attention",
      headline: "Governance risks detected — review recommended"
    }

  }

  if (digest.highest_severity === "warning") {

    return {
      status: "attention",
      headline: "Governance warnings present"
    }

  }

  return {
    status: "healthy",
    headline: "No governance concerns detected"
  }

}
