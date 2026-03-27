import { runGovernanceAdvisoryPipeline } from "./governance_advisory_pipeline"

export function verifyGovernanceAdvisoryConsistency(fixture:any){

  const advisory =
    runGovernanceAdvisoryPipeline(fixture)

  const status =
    advisory.operator_view.status

  const signals =
    advisory.governance_signals || []

  let expected = "normal"

  const hasCritical =
    signals.some((s:any)=>s.level === "critical")

  const hasWarning =
    signals.some((s:any)=>s.level === "warning")

  if(hasCritical){
    expected = "critical"
  }
  else if(hasWarning){
    expected = "warning"
  }

  const mismatch =
    expected !== status

  return {

    advisory_status: status,

    expected_status: expected,

    consistency_verified: !mismatch,

    governance_alignment:
      mismatch ? "review_required" : "aligned"

  }

}
