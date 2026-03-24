/*
Phase 151D — Registry Verification Surface

Purpose:
Define deterministic verification rules required before any registry mutation may execute.

NO mutation execution enabled.
Verification scaffold only.
*/

import { CapabilityMetadata } from "./registry_owner"

export type RegistryVerificationResult = {
  capability_id: string
  verified: boolean
  reason?: string
}

export class RegistryVerifier {

  verifyCapabilityMetadata(
    capability: CapabilityMetadata
  ): RegistryVerificationResult {

    // Phase 151D rule:
    // Verification scaffold only — no live mutation yet.

    if (!capability.capability_id) {
      return {
        capability_id: capability.capability_id,
        verified: false,
        reason: "Missing capability_id"
      }
    }

    if (!capability.governance_class) {
      return {
        capability_id: capability.capability_id,
        verified: false,
        reason: "Missing governance_class"
      }
    }

    if (!capability.execution_boundaries) {
      return {
        capability_id: capability.capability_id,
        verified: false,
        reason: "Missing execution_boundaries"
      }
    }

    if (!capability.authority_scope) {
      return {
        capability_id: capability.capability_id,
        verified: false,
        reason: "Missing authority_scope"
      }
    }

    return {
      capability_id: capability.capability_id,
      verified: true
    }

  }

}
