/*
Phase 151H — Registry Owner Integration

Purpose:
Make RegistryOwner the single controlled entrypoint for all registry mutation.

RegistryOwner becomes the only component allowed to submit mutation
requests to the RegistryMutationCoordinator.

This preserves the single-owner mutation doctrine.
*/

import { RegistryMutationCoordinator } from "./registry_mutation_coordinator"

export type CapabilityMetadata = {
  capability_id: string
  governance_class: string
  description: string
  created_by: string
  created_at: string
}

export type RegistryMutationRequest = {
  mutation_id: string
  operator_id: string
  mutation_type: string
  capability: CapabilityMetadata
  timestamp: string
}

export type RegistryMutationResult = {
  mutation_id: string
  accepted: boolean
  reason?: string
}

export class RegistryOwner {
  private coordinator: RegistryMutationCoordinator
  private ownerId: string

  constructor(
    coordinator: RegistryMutationCoordinator,
    ownerId = "registry-owner"
  ) {
    this.coordinator = coordinator
    this.ownerId = ownerId
  }

  registerCapability(
    operatorId: string,
    capability: CapabilityMetadata
  ): RegistryMutationResult {

    const request: RegistryMutationRequest = {
      mutation_id: `${capability.capability_id}::register::${Date.now()}`,
      operator_id: operatorId,
      mutation_type: "CAPABILITY_METADATA_REGISTER",
      capability,
      timestamp: new Date().toISOString()
    }

    return this.coordinator.evaluateMutation(request)
  }

  getOwnerId(): string {
    return this.ownerId
  }

}
