import { runGovernanceAdvisoryPipeline } from "./governance_advisory_pipeline"

export function verifyGovernanceReplayStability(fixture:any){

  const results = []

  for(let i=0;i<5;i++){

    results.push(
      runGovernanceAdvisoryPipeline(fixture)
        .operator_view.status
    )

  }

  const baseline = results[0]

  const drift =
    results.some(r => r !== baseline)

  if(drift){

    throw new Error(
      "Governance cognition replay instability detected"
    )

  }

  return {

    replay_runs: results.length,

    baseline_status: baseline,

    cognition_replay: "stable",

    governance_reliability: "verified"

  }

}
