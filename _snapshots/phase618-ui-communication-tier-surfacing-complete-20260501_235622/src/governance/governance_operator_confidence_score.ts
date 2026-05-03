import { runGovernanceAdvisoryPipeline } from "./governance_advisory_pipeline"

export function computeGovernanceOperatorConfidence(fixture:any){

  const advisory =
    runGovernanceAdvisoryPipeline(fixture)

  const signals =
    advisory.governance_signals || []

  let score = 100

  signals.forEach((s:any)=>{

    if(s.level === "warning"){
      score -= 15
    }

    if(s.level === "critical"){
      score -= 40
    }

  })

  if(score < 0){
    score = 0
  }

  let confidence_band = "high"

  if(score < 70){
    confidence_band = "moderate"
  }

  if(score < 40){
    confidence_band = "low"
  }

  return {

    governance_confidence_score: score,

    governance_confidence_band: confidence_band,

    advisory_basis: signals.length,

    cognition_interpretation: "signal_weighted"

  }

}
