import { runGovernanceAdvisoryPipeline } from "./governance_advisory_pipeline"

export function buildGovernanceOperatorExplanation(fixture:any){

  const advisory =
    runGovernanceAdvisoryPipeline(fixture)

  const status =
    advisory.operator_view.status

  let explanation = "System operating within governance bounds"

  if(status === "warning"){

    explanation =
      "Governance signals indicate caution. Operator review recommended."

  }

  if(status === "critical"){

    explanation =
      "Governance signals indicate elevated risk. Operator attention required before continuation."

  }

  return {

    governance_status: status,

    operator_explanation: explanation,

    cognition_visibility: "transparent",

    authority_model: "human_decides_system_informs"

  }

}
