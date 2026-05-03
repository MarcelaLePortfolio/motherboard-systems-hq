import { runGovernanceAdvisoryPipeline } from "./governance_advisory_pipeline"

export function computeGovernanceSignalStabilityIndex(fixture:any){

  const advisory =
    runGovernanceAdvisoryPipeline(fixture)

  const signals =
    advisory.governance_signals || []

  let instability = 0

  signals.forEach((s:any)=>{

    if(s.level === "warning"){
      instability += 1
    }

    if(s.level === "critical"){
      instability += 3
    }

  })

  const stability =
    Math.max(0, 100 - (instability * 10))

  let stability_band = "stable"

  if(stability < 70){
    stability_band = "variable"
  }

  if(stability < 40){
    stability_band = "unstable"
  }

  return {

    governance_stability_index: stability,

    stability_band,

    signal_volume: signals.length,

    governance_predictability:
      stability_band === "stable"
        ? "high"
        : "review"

  }

}
