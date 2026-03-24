/*
Phase 151K — Registry Integrated Summary Surface

Purpose:
Provide a single deterministic operator-safe summary of registry state.

This surface aggregates:

Capability totals
Governance class distribution
Registry health flag
Diagnostics signals

This surface is strictly read-only.

NO mutation allowed.
*/

import { RegistryReadSurface } from "./registry_read_surface"
import { RegistryVisibilityDiagnostics } from "./registry_visibility_diagnostics"

export type RegistrySummary = {
  capability_total: number
  governance_class_totals: Record<string, number>
  registry_healthy: boolean
  invalid_capability_count: number
  duplicate_capability_count: number
}

export class RegistrySummarySurface {

  private readSurface: RegistryReadSurface
  private diagnostics: RegistryVisibilityDiagnostics

  constructor(
    readSurface: RegistryReadSurface,
    diagnostics: RegistryVisibilityDiagnostics
  ) {
    this.readSurface = readSurface
    this.diagnostics = diagnostics
  }

  generateSummary(): RegistrySummary {

    const capabilities = this.readSurface.listCapabilities()
    const diagnosticReport = this.diagnostics.generateReport()

    const governanceTotals: Record<string, number> = {}

    capabilities.forEach(capability => {

      const gClass = capability.governance_class

      if (!governanceTotals[gClass]) {
        governanceTotals[gClass] = 0
      }

      governanceTotals[gClass]++

    })

    return {
      capability_total: capabilities.length,
      governance_class_totals: governanceTotals,
      registry_healthy: diagnosticReport.healthy,
      invalid_capability_count: diagnosticReport.invalid_capabilities.length,
      duplicate_capability_count: diagnosticReport.duplicate_capability_ids.length
    }

  }

}
