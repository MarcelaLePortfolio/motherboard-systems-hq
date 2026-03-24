export interface CognitionTransportDiagnostics {
  registryHealthy: boolean
  verificationHealthy: boolean
  policyGateHealthy: boolean
  invariantHealthy: boolean

  replaySafe: boolean

  lastVerificationTs: number | null

  failureCount: number

  notes?: string[]
}
