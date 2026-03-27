import { runGovernanceAdvisoryPipeline }
from "./governance_advisory_pipeline"

export function verifyGovernanceAdvisoryContract() {

  const result =
    runGovernanceAdvisoryPipeline({
      signals: []
    })

  if (typeof result !== "object") {
    throw new Error("Governance advisory drift: result shape changed")
  }

  if (!("operator_view" in result)) {
    throw new Error("Governance advisory drift: operator_view missing")
  }

  if (!("system_view" in result)) {
    throw new Error("Governance advisory drift: system_view missing")
  }

  if (!("status" in result.operator_view)) {
    throw new Error("Governance advisory drift: operator status missing")
  }

  return {

    advisory_contract: "locked",

    governance_shape: "verified",

    operator_contract: "protected",

    system_contract: "protected"

  }

}
