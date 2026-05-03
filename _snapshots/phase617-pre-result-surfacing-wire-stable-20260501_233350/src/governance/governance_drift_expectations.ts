import { runGovernanceDriftSentinel } from "./governance_drift_sentinel"

export function verifyGovernanceDriftExpectations() {

  const result =
    runGovernanceDriftSentinel()

  if (result.empty_status !== "healthy") {
    throw new Error("Governance drift: EMPTY fixture changed")
  }

  if (result.critical_status !== "critical") {
    throw new Error("Governance drift: CRITICAL fixture changed")
  }

  if (result.warning_status !== "attention") {
    throw new Error("Governance drift: WARNING fixture changed")
  }

  if (result.mixed_status !== "critical") {
    throw new Error("Governance drift: MIXED fixture changed")
  }

  return {
    status: "governance-stable"
  }

}
