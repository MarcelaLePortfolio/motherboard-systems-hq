/*
PHASE 115 — TRANSPORT INTERPRETATION SURFACE
Deterministic cognition-only interpretation layer
*/

import { getCognitionTransportLabel } from "./cognitionTransport.label"
import { getCognitionTransportSeverity } from "./cognitionTransport.severity"
import { getCognitionTransportSummary } from "./cognitionTransport.summary"

export interface CognitionTransportInterpretation {
  label: string
  severity: string
  healthy: boolean
  replaySafe: boolean
  registryConsistent: boolean
  reasons: string[]
  deterministic: true
}

export function getCognitionTransportInterpretation(): CognitionTransportInterpretation {
  const label = getCognitionTransportLabel()
  const severity = getCognitionTransportSeverity()
  const summary = getCognitionTransportSummary()

  return {
    label: label.label,
    severity: severity.severity,
    healthy: summary.healthy,
    replaySafe: summary.replaySafe,
    registryConsistent: summary.registryConsistent,
    reasons: severity.reasons,
    deterministic: true
  }
}

/*
Rules:

Read-only interpretation only
No runtime mutation
No execution coupling
Deterministic cognition surface only
*/
