import { CognitionTransportDiagnostics } from "./CognitionTransportDiagnostics.types"
import { assertTransportReplaySafety } from "./transportReplaySafety.assert"

export function buildTransportDiagnostics(input: {
  registryHealthy: boolean
  verificationHealthy: boolean
  policyGateHealthy: boolean
  invariantHealthy: boolean
  snapshot?: unknown
  failureCount?: number
}): CognitionTransportDiagnostics {

  const replaySafe = assertTransportReplaySafety(input.snapshot)

  return {
    registryHealthy: input.registryHealthy,
    verificationHealthy: input.verificationHealthy,
    policyGateHealthy: input.policyGateHealthy,
    invariantHealthy: input.invariantHealthy,

    replaySafe,

    lastVerificationTs: Date.now(),

    failureCount: input.failureCount ?? 0,

    notes: replaySafe ? [] : ["transport snapshot not replay safe"]
  }
}
