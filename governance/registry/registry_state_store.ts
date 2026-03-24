/*
Phase 151G — Registry State Store

Purpose:
Provide the first controlled in-memory registry state surface for
metadata-only capability registration.

This store is intentionally minimal.

Allowed mutation:
Add capability metadata only.

Forbidden:
Update existing capability metadata
Delete capability metadata
Route execution
Expand authority
*/

import { CapabilityMetadata } from "./registry_owner"

export class RegistryStateStore {
  private capabilityMetadata = new Map<string, CapabilityMetadata>()

  hasCapability(capabilityId: string): boolean {
    return this.capabilityMetadata.has(capabilityId)
  }

  registerCapabilityMetadata(capability: CapabilityMetadata): void {
    if (this.capabilityMetadata.has(capability.capability_id)) {
      throw new Error(
        `Capability metadata already exists for capability_id=${capability.capability_id}`
      )
    }

    this.capabilityMetadata.set(capability.capability_id, { ...capability })
  }

  getCapabilityMetadata(capabilityId: string): CapabilityMetadata | undefined {
    const capability = this.capabilityMetadata.get(capabilityId)
    return capability ? { ...capability } : undefined
  }

  getAllCapabilityMetadata(): CapabilityMetadata[] {
    return Array.from(this.capabilityMetadata.values()).map((capability) => ({
      ...capability
    }))
  }

  restoreFromCapabilities(capabilities: CapabilityMetadata[]): void {
    this.capabilityMetadata = new Map(
      capabilities.map((capability) => [capability.capability_id, { ...capability }])
    )
  }
}
