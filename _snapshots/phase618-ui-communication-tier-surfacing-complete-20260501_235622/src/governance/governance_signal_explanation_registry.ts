import { runGovernanceAdvisoryPipeline } from "./governance_advisory_pipeline"

export function buildGovernanceSignalExplanationRegistry(fixture:any){

  const advisory =
    runGovernanceAdvisoryPipeline(fixture)

  const signals =
    advisory.governance_signals || []

  const registry =
    signals.map((s:any)=>{

      let explanation =
        "Signal detected. No additional interpretation available."

      if(s.level === "warning"){
        explanation =
          "This signal suggests caution. Operator review may improve outcome safety."
      }

      if(s.level === "critical"){
        explanation =
          "This signal indicates elevated operational risk requiring operator attention."
      }

      return {

        signal_type:
          s.type || "unknown",

        signal_level:
          s.level || "unknown",

        explanation,

        system_role:
          "informational",

        operator_action:
          "review"

      }

    })

  return {

    governance_signal_registry: registry,

    cognition_transparency: "enabled",

    operator_visibility: "full"

  }

}
