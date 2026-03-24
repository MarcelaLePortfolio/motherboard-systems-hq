/*
Phase 151E/151F — Registry Mutation Coordinator (Safety Orchestration Surface)

Purpose:
Define the deterministic orchestration layer that coordinates:

Verification
Policy gating
Logging
Snapshot dependency presence

NO mutation execution enabled.
Coordinator scaffold only.
*/

import { RegistryMutationRequest, RegistryMutationResult } from "./registry_owner"
import { RegistryMutationLogger } from "./registry_mutation_logger"
import { RegistrySnapshotManager } from "./registry_snapshot_manager"
import { RegistryVerifier } from "./registry_verifier"
import { RegistryMutationEnablementPolicyManager } from "./registry_mutation_enablement_policy"

export class RegistryMutationCoordinator {
  private logger: RegistryMutationLogger
  private snapshotManager: RegistrySnapshotManager
  private verifier: RegistryVerifier
  private policyManager: RegistryMutationEnablementPolicyManager

  constructor(
    logger: RegistryMutationLogger,
    snapshotManager: RegistrySnapshotManager,
    verifier: RegistryVerifier,
    policyManager: RegistryMutationEnablementPolicyManager
  ) {
    this.logger = logger
    this.snapshotManager = snapshotManager
    this.verifier = verifier
    this.policyManager = policyManager
  }

  evaluateMutation(
    request: RegistryMutationRequest
  ): RegistryMutationResult {
    // Phase 151E/151F rule:
    // Coordination + policy gating only — mutation remains disabled.

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

    const policy = this.policyManager.getPolicy()

    if (!policy.registry_mutation_enabled) {
      this.logger.record({
        mutation_id: request.mutation_id,
        operator_id: request.operator_id,
        capability_id: request.capability.capability_id,
        mutation_type: request.mutation_type,
        governance_class: request.capability.governance_class,
        timestamp: request.timestamp,
        verification_state: "verified",
        result: "rejected",
        reason: "Registry mutation disabled by enablement policy"
      })

      return {
        mutation_id: request.mutation_id,
        accepted: false,
        reason: "Registry mutation disabled by enablement policy"
      }
    }

    if (
      !this.policyManager.isGovernanceClassAllowed(
        request.capability.governance_class
      )
    ) {
      this.logger.record({
        mutation_id: request.mutation_id,
        operator_id: request.operator_id,
        capability_id: request.capability.capability_id,
        mutation_type: request.mutation_type,
        governance_class: request.capability.governance_class,
        timestamp: request.timestamp,
        verification_state: "verified",
        result: "rejected",
        reason: "Governance class not allowed by enablement policy"
      })

      return {
        mutation_id: request.mutation_id,
        accepted: false,
        reason: "Governance class not allowed by enablement policy"
      }
    }

    // Mutation still blocked until later phase even if policy allows consideration.

    this.logger.record({
      mutation_id: request.mutation_id,
      operator_id: request.operator_id,
      capability_id: request.capability.capability_id,
      mutation_type: request.mutation_type,
      governance_class: request.capability.governance_class,
      timestamp: request.timestamp,
      verification_state: "verified",
      result: "rejected",
      reason: "Registry mutation execution not enabled (Phase 151F gate only)"
    })

    return {
      mutation_id: request.mutation_id,
      accepted: false,
      reason: "Registry mutation execution not enabled (Phase 151F gate only)"
    }
  }

  getSnapshotCount(): number {
    return this.snapshotManager.getSnapshots().length
  }
}
