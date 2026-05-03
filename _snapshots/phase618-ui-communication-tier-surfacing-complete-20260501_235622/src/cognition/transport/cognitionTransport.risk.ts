/*
PHASE 116 — TRANSPORT RISK CLASSIFICATION
Deterministic governance-ready cognition classification
*/

import { getCognitionTransportSeverity } from "./cognitionTransport.severity"

export type TransportRiskLevel =
  | "NONE"
  | "LOW"
  | "MODERATE"
  | "HIGH"

export interface CognitionTransportRisk {
  risk: TransportRiskLevel
  deterministic: true
  reasons: string[]
}

export function getCognitionTransportRisk(): CognitionTransportRisk {

  const severity = getCognitionTransportSeverity()

  let risk: TransportRiskLevel = "NONE"

  if (severity.severity === "HEALTHY")
    risk = "NONE"
  else if (severity.severity === "DEGRADED")
    risk = "LOW"
  else if (severity.severity === "UNSTABLE")
    risk = "MODERATE"
  else
    risk = "HIGH"

  return {
    risk,
    deterministic: true,
    reasons: severity.reasons
  }
}

/*
Rules:

Pure classification only
No runtime mutation
No authority expansion
Governance-readable only
*/
