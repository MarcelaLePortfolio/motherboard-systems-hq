/*
PHASE 118 — OPERATOR PRESENTATION CONTRACT
Deterministic presentation model for operator cognition surfaces
*/

import { getCognitionTransportOperatorView } from "./cognitionTransport.operatorView"

export type TransportPresentationTone =
  | "NORMAL"
  | "ATTENTION"
  | "WARNING"
  | "CRITICAL"

export interface CognitionTransportPresentation {
  title: string
  tone: TransportPresentationTone
  summary: string
  governanceReady: boolean
  deterministic: true
}

function severityToTone(severity: string): TransportPresentationTone {
  if (severity === "HEALTHY") return "NORMAL"
  if (severity === "DEGRADED") return "ATTENTION"
  if (severity === "UNSTABLE") return "WARNING"
  return "CRITICAL"
}

export function getCognitionTransportPresentation(): CognitionTransportPresentation {

  const view = getCognitionTransportOperatorView()

  return {
    title: "Cognition Transport",
    tone: severityToTone(view.severity),
    summary: view.label,
    governanceReady: view.governanceReady,
    deterministic: true
  }
}

/*
Rules:

Presentation only
No runtime mutation
No execution authority
Operator cognition presentation contract only
*/
