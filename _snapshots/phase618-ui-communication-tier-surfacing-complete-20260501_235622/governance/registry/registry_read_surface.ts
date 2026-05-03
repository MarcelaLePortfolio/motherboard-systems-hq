/*
Phase 151I — Registry Capability Read Surface

Purpose:
Provide a strictly read-only visibility surface over registry capabilities.

This surface allows:

Capability listing
Capability lookup
Governance class inspection
Registry visibility tooling

This surface does NOT allow:

Mutation
Routing changes
Execution changes
Authority expansion
*/

import { RegistryStateStore } from "./registry_state_store"
import { CapabilityMetadata } from "./registry_owner"

export class RegistryReadSurface {

  private stateStore: RegistryStateStore

  constructor(stateStore: RegistryStateStore) {
    this.stateStore = stateStore
  }

  listCapabilities(): CapabilityMetadata[] {

    return this.stateStore
      .getAllCapabilityMetadata()
      .map(capability => ({ ...capability }))

  }

  getCapability(
    capabilityId: string
  ): CapabilityMetadata | undefined {

    const capability =
      this.stateStore.getCapabilityMetadata(capabilityId)

    return capability ? { ...capability } : undefined

  }

  listGovernanceClasses(): string[] {

    const classes = new Set<string>()

    this.stateStore
      .getAllCapabilityMetadata()
      .forEach(capability => {

        classes.add(capability.governance_class)

      })

    return Array.from(classes)

  }

  capabilityCount(): number {

    return this.stateStore
      .getAllCapabilityMetadata()
      .length

  }

}
