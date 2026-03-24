/*
Phase 151J — Registry Visibility Diagnostics Surface

Purpose:
Provide a strictly read-only diagnostics surface over registry state.

This surface allows:

Registry health inspection
Capability integrity checks
Governance classification diagnostics
Registry consistency checks

This surface does NOT allow:

Mutation
Routing changes
Execution changes
Authority expansion
*/

import { RegistryReadSurface } from "./registry_read_surface"
import { CapabilityMetadata } from "./registry_owner"

export type RegistryCapabilityDiagnostic = {
  capability_id: string
  present: boolean
  governance_class_present: boolean
  description_present: boolean
  created_by_present: boolean
  created_at_present: boolean
  valid: boolean
}

export type RegistryVisibilityDiagnosticReport = {
  healthy: boolean
  capability_count: number
  governance_classes: string[]
  duplicate_capability_ids: string[]
  invalid_capabilities: RegistryCapabilityDiagnostic[]
}

export class RegistryVisibilityDiagnostics {
  private readSurface: RegistryReadSurface

  constructor(readSurface: RegistryReadSurface) {
    this.readSurface = readSurface
  }

  inspectCapability(capability: CapabilityMetadata): RegistryCapabilityDiagnostic {
    const governanceClassPresent = capability.governance_class.trim().length > 0
    const descriptionPresent = capability.description.trim().length > 0
    const createdByPresent = capability.created_by.trim().length > 0
    const createdAtPresent = capability.created_at.trim().length > 0

    const valid =
      capability.capability_id.trim().length > 0 &&
      governanceClassPresent &&
      descriptionPresent &&
      createdByPresent &&
      createdAtPresent

    return {
      capability_id: capability.capability_id,
      present: capability.capability_id.trim().length > 0,
      governance_class_present: governanceClassPresent,
      description_present: descriptionPresent,
      created_by_present: createdByPresent,
      created_at_present: createdAtPresent,
      valid
    }
  }

  generateReport(): RegistryVisibilityDiagnosticReport {
    const capabilities = this.readSurface.listCapabilities()
    const diagnostics = capabilities.map((capability) =>
      this.inspectCapability(capability)
    )

    const seen = new Set<string>()
    const duplicates = new Set<string>()

    capabilities.forEach((capability) => {
      if (seen.has(capability.capability_id)) {
        duplicates.add(capability.capability_id)
      } else {
        seen.add(capability.capability_id)
      }
    })

    const invalidCapabilities = diagnostics.filter((diagnostic) => !diagnostic.valid)

    return {
      healthy: duplicates.size === 0 && invalidCapabilities.length === 0,
      capability_count: capabilities.length,
      governance_classes: this.readSurface.listGovernanceClasses(),
      duplicate_capability_ids: Array.from(duplicates),
      invalid_capabilities: invalidCapabilities
    }
  }
}
