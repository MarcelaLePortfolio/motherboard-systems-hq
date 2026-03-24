/*
PHASE 115 — TRANSPORT DIAGNOSTICS SEVERITY MODEL
Deterministic cognition-only classification
*/

import { getCognitionTransportSummary } from "./cognitionTransport.summary"

export type TransportSeverity =
  | "HEALTHY"
  | "DEGRADED"
  | "UNSTABLE"
  | "CRITICAL"

export interface CognitionTransportSeverity {
  severity: TransportSeverity
  deterministic: true
  reasons: string[]
}

export function getCognitionTransportSeverity(): CognitionTransportSeverity {

  const summary = getCognitionTransportSummary()

  const reasons: string[] = []

  if (!summary.registryConsistent)
    reasons.push("registry inconsistent")

  if (!summary.replaySafe)
    reasons.push("replay unsafe")

  if (summary.failureCount > 0)
    reasons.push("transport failures detected")

  let severity: TransportSeverity = "HEALTHY"

  if (reasons.length === 0)
    severity = "HEALTHY"
  else if (reasons.length === 1)
    severity = "DEGRADED"
  else if (reasons.length === 2)
    severity = "UNSTABLE"
  else
    severity = "CRITICAL"

  return {
    severity,
    deterministic: true,
    reasons
  }
}

/*
Rules:

Pure classification only
No runtime mutation
No execution authority
Deterministic cognition labeling
*/
