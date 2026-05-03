import { runGovernanceAdvisoryPipeline }
from "./governance_advisory_pipeline"

export function verifyGovernanceCognitionIntegrity() {

  const result =
    runGovernanceAdvisoryPipeline({
      signals: []
    })

  if (!result.operator_view) {
    throw new Error("Governance cognition drift: operator view missing")
  }

  if (!result.operator_view.status) {
    throw new Error("Governance cognition drift: operator status missing")
  }

  if (!result.system_view) {
    throw new Error("Governance cognition drift: system view missing")
  }

  return {

    cognition_integrity: "verified",

    operator_contract: "intact",

    system_contract: "intact",

    advisory_output: "protected"

  }

}
