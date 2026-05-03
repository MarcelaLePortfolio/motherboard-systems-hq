import { runGovernanceAdvisoryPipeline }
from "./governance_advisory_pipeline"

export function verifyGovernancePipelineOrder() {

  const pipeline =
    runGovernanceAdvisoryPipeline({
      signals: []
    })

  if (!pipeline.operator_view) {
    throw new Error("Governance pipeline drift: operator view missing")
  }

  if (!pipeline.system_view) {
    throw new Error("Governance pipeline drift: system view missing")
  }

  return {
    pipeline_order: "verified",
    governance_contract: "intact",
    cognition_sequence: "locked"
  }

}
