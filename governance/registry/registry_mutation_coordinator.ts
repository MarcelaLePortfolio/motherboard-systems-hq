/*
Phase 151E — Registry Mutation Coordinator (Safety Orchestration Surface)

Purpose:
Define the deterministic orchestration layer that will eventually coordinate:

Authorization
Verification
Snapshot creation
Logging

NO mutation execution enabled.
Coordinator scaffold only.
*/

import { RegistryMutationRequest, RegistryMutationResult } from "./registry_owner"
import { RegistryMutationLogger } from "./registry_mutation_logger"
import { RegistrySnapshotManager } from "./registry_snapshot_manager"
import { RegistryVerifier } from "./registry_verifier"

export class RegistryMutationCoordinator {

  private logger: RegistryMutationLogger
  private snapshotManager: RegistrySnapshotManager
  private verifier: RegistryVerifier

  constructor(
    logger: RegistryMutationLogger,
    snapshotManager: RegistrySnapshotManager,
    verifier: RegistryVerifier
  ) {
    this.logger = logger
    this.snapshotManager = snapshotManager
    this.verifier = verifier
  }

  evaluateMutation(
    request: RegistryMutationRequest
  ): RegistryMutationResult {

    // Phase 151E rule:
    // Coordination logic only — mutation remains disabled.

    const verification = this.verifier.verifyCapabilityMetadata(
      request.capability
    )

    if (!verification.verified) {

      this.logger.record({
        mutation_id: request.mutation_id,
        operator_id: request.operator_id,
        capability_id: request.capability.capability_id,
        mutation_type: request.mutation_type,
        governance_class: request.capability.governance_class,
        timestamp: request.timestamp,
        verification_state: "rejected",
        result: "rejected",
        reason: verification.reason
      })

      return {
        mutation_id: request.mutation_id,
        accepted: false,
        reason: verification.reason
      }

    }

    // Mutation still blocked until later phase.

    return {
      mutation_id: request.mutation_id,
      accepted: false,
      reason: "Registry mutation not enabled (Phase 151E safety coordination only)"
    }

  }

}
