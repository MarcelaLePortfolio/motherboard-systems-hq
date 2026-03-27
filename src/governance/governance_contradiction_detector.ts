import { runGovernanceAdvisoryPipeline } from "./governance_advisory_pipeline"

export function detectGovernanceContradictions(fixture:any){

  const advisory =
    runGovernanceAdvisoryPipeline(fixture)

  const signals =
    advisory.governance_signals || []

  let criticalCount = 0
  let warningCount = 0

  signals.forEach((s:any)=>{

    if(s.level === "critical"){
      criticalCount++
    }

    if(s.level === "warning"){
      warningCount++
    }

  })

  const contradiction =
    criticalCount > 0 &&
    warningCount > 0

  return {

    contradiction_detected: contradiction,

    critical_signals: criticalCount,

    warning_signals: warningCount,

    governance_consistency:
      contradiction ? "review_recommended" : "consistent"

  }

}
