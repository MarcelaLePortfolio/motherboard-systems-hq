/*
PHASE 115 — TRANSPORT COGNITION LABEL MODEL
Deterministic operator-readable labeling surface
*/

import {
  getCognitionTransportSeverity,
  TransportSeverity
} from "./cognitionTransport.severity"

export interface CognitionTransportLabel {
  label: string
  severity: TransportSeverity
  deterministic: true
}

function severityToLabel(severity: TransportSeverity): string {
  switch (severity) {
    case "HEALTHY":
      return "Transport healthy"
    case "DEGRADED":
      return "Transport degraded"
    case "UNSTABLE":
      return "Transport unstable"
    case "CRITICAL":
      return "Transport critical"
  }
}

export function getCognitionTransportLabel(): CognitionTransportLabel {
  const { severity } = getCognitionTransportSeverity()

  return {
    label: severityToLabel(severity),
    severity,
    deterministic: true
  }
}

/*
Rules:

Pure labeling only
No runtime mutation
No execution authority
Deterministic cognition readability
*/
