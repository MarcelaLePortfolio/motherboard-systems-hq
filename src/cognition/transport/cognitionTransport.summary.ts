/*
PHASE 115 — TRANSPORT DIAGNOSTICS SUMMARY
Deterministic aggregation surface (read-only)
*/

import { buildCognitionTransportDiagnostics } from "./cognitionTransport.diagnostics"
import { getCognitionTransportReplayReport } from "./cognitionTransport.replay"

export interface CognitionTransportSummary {
  healthy: boolean
  replaySafe: boolean
  registryConsistent: boolean
  failureCount: number
  timestamp: number
  deterministic: true
}

export function getCognitionTransportSummary(): CognitionTransportSummary {

  const diagnostics = buildCognitionTransportDiagnostics()
  const replay = getCognitionTransportReplayReport()

  return {
    healthy:
      diagnostics.registryHealthy &&
      diagnostics.verificationHealthy &&
      diagnostics.policyGateHealthy &&
      diagnostics.invariantHealthy,

    replaySafe: replay.replaySafe,

    registryConsistent: replay.registryConsistent,

    failureCount: diagnostics.failureCount,

    timestamp: Date.now(),

    deterministic: true
  }
}

/*
Rules:

Read-only aggregation only
No execution coupling
No runtime mutation
Cognition visibility only
*/
