/*
PHASE 117 — OPERATOR COGNITION SURFACE
Deterministic operator-facing aggregation
*/

import { getCognitionTransportInterpretation } from "./cognitionTransport.interpretation"
import { getCognitionTransportGovernanceReadiness } from "./cognitionTransport.governance"

export interface CognitionTransportOperatorView {
  label: string
  severity: string
  governanceReady: boolean
  notes: string[]
  deterministic: true
}

export function getCognitionTransportOperatorView(): CognitionTransportOperatorView {

  const interpretation = getCognitionTransportInterpretation()
  const governance = getCognitionTransportGovernanceReadiness()

  const notes = [
    ...interpretation.reasons,
    ...governance.notes
  ]

  return {
    label: interpretation.label,
    severity: interpretation.severity,
    governanceReady: governance.governanceReady,
    notes,
    deterministic: true
  }
}

/*
Rules:

Operator cognition only
Read-only aggregation
No runtime mutation
No execution coupling
*/
