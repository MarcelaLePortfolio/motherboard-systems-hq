/*
Phase 151E/151F/151G — Registry Mutation Coordinator

Purpose:
Define the deterministic orchestration layer that coordinates:

Verification
Policy gating
Snapshot creation
Logging
Metadata-only registration
Post-write verification
Rollback on failure

Allowed execution in Phase 151G:
Single metadata-only capability registration path.

All other mutation classes remain disabled.
*/

import { RegistryMutationRequest, RegistryMutationResult } from "./registry_owner"
import { RegistryMutationLogger } from "./registry_mutation_logger"
import { RegistrySnapshotManager } from "./registry_snapshot_manager"
import { RegistryVerifier } from "./registry_verifier"
import { RegistryMutationEnablementPolicyManager } from "./registry_mutation_enablement_policy"
import { RegistryStateStore } from "./registry_state_store"

export class RegistryMutationCoordinator {
  private logger: RegistryMutationLogger
  private snapshotManager: RegistrySnapshotManager
  private verifier: RegistryVerifier
  private policyManager: RegistryMutationEnablementPolicyManager
  private stateStore: RegistryStateStore
  private registryOwnerId: string
  private authorizationModelVersion: string
  private registryVersion: string

  constructor(
    logger: RegistryMutationLogger,
    snapshotManager: RegistrySnapshotManager,
    verifier: RegistryVerifier,
    policyManager: RegistryMutationEnablementPolicyManager,
    stateStore: RegistryStateStore,
    registryOwnerId = "registry-owner",
    authorizationModelVersion = "phase151g-authorized-metadata-only",
    registryVersion = "phase151g"
  ) {
    this.logger = logger
    this.snapshotManager = snapshotManager
    this.verifier = verifier
    this.policyManager = policyManager
    this.stateStore = stateStore
    this.registryOwnerId = registryOwnerId
    this.authorizationModelVersion = authorizationModelVersion
    this.registryVersion = registryVersion
  }

  evaluateMutation(
    request: RegistryMutationRequest
  ): RegistryMutationResult {
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

    if (this.stateStore.hasCapability(request.capability.capability_id)) {
      this.logger.record({
        mutation_id: request.mutation_id,
        operator_id: request.operator_id,
        capability_id: request.capability.capability_id,
        mutation_type: request.mutation_type,
        governance_class: request.capability.governance_class,
        timestamp: request.timestamp,
        verification_state: "rejected",
        result: "rejected",
        reason: "Capability metadata already registered"
      })

      return {
        mutation_id: request.mutation_id,
        accepted: false,
        reason: "Capability metadata already registered"
      }
    }

    const snapshotId = `${request.mutation_id}::snapshot::prewrite`

    this.snapshotManager.createSnapshot({
      snapshot_id: snapshotId,
      timestamp: request.timestamp,
      registry_owner: this.registryOwnerId,
      capability_ids: this.stateStore
        .getAllCapabilityMetadata()
        .map((capability) => capability.capability_id),
      governance_classes: this.stateStore
        .getAllCapabilityMetadata()
        .map((capability) => capability.governance_class),
      authorization_model_version: this.authorizationModelVersion,
      registry_version: this.registryVersion,
      capabilities: this.stateStore.getAllCapabilityMetadata()
    })

    this.logger.record({
      mutation_id: request.mutation_id,
      operator_id: request.operator_id,
      capability_id: request.capability.capability_id,
      mutation_type: request.mutation_type,
      governance_class: request.capability.governance_class,
      timestamp: request.timestamp,
      snapshot_id: snapshotId,
      verification_state: "verified",
      result: "accepted",
      reason: "Pre-write verification and snapshot complete"
    })

    try {
      this.stateStore.registerCapabilityMetadata(request.capability)

      const postWriteVerification = this.verifier.verifyCapabilityMetadata(
        request.capability
      )

      if (!postWriteVerification.verified) {
        const latestSnapshot = this.snapshotManager.getLatestSnapshot()

        if (!latestSnapshot) {
          throw new Error("Rollback snapshot missing")
        }

        this.stateStore.restoreFromCapabilities(latestSnapshot.capabilities)

        this.logger.record({
          mutation_id: request.mutation_id,
          operator_id: request.operator_id,
          capability_id: request.capability.capability_id,
          mutation_type: request.mutation_type,
          governance_class: request.capability.governance_class,
          timestamp: request.timestamp,
          snapshot_id: snapshotId,
          verification_state: "rejected",
          result: "rejected",
          reason: `Post-write verification failed: ${postWriteVerification.reason}`
        })

        return {
          mutation_id: request.mutation_id,
          accepted: false,
          reason: `Post-write verification failed: ${postWriteVerification.reason}`
        }
      }

      this.logger.record({
        mutation_id: request.mutation_id,
        operator_id: request.operator_id,
        capability_id: request.capability.capability_id,
        mutation_type: request.mutation_type,
        governance_class: request.capability.governance_class,
        timestamp: request.timestamp,
        snapshot_id: snapshotId,
        verification_state: "verified",
        result: "accepted",
        reason: "Capability metadata registered"
      })

      return {
        mutation_id: request.mutation_id,
        accepted: true
      }
    } catch (error) {
      const latestSnapshot = this.snapshotManager.getLatestSnapshot()

      if (latestSnapshot) {
        this.stateStore.restoreFromCapabilities(latestSnapshot.capabilities)
      }

      const reason =
        error instanceof Error ? error.message : "Unknown registry mutation failure"

      this.logger.record({
        mutation_id: request.mutation_id,
        operator_id: request.operator_id,
        capability_id: request.capability.capability_id,
        mutation_type: request.mutation_type,
        governance_class: request.capability.governance_class,
        timestamp: request.timestamp,
        snapshot_id: snapshotId,
        verification_state: "rejected",
        result: "rejected",
        reason: `Mutation rolled back: ${reason}`
      })

      return {
        mutation_id: request.mutation_id,
        accepted: false,
        reason: `Mutation rolled back: ${reason}`
      }
    }
  }

  getSnapshotCount(): number {
    return this.snapshotManager.getSnapshots().length
  }

  getRegisteredCapabilityCount(): number {
    return this.stateStore.getAllCapabilityMetadata().length
  }
}
