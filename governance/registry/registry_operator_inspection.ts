/*
Phase 151L — Registry Operator Inspection Interface

Purpose:
Provide a deterministic operator-facing inspection interface for registry state.

This interface composes:

Read surface
Diagnostics surface
Summary surface

This interface is strictly read-only.

NO mutation allowed.
*/

import { RegistryReadSurface } from "./registry_read_surface"
import { RegistryVisibilityDiagnostics } from "./registry_visibility_diagnostics"
import { RegistrySummarySurface } from "./registry_summary_surface"

export type RegistryOperatorInspectionReport = {
  summary: ReturnType<RegistrySummarySurface["generateSummary"]>
  diagnostics: ReturnType<RegistryVisibilityDiagnostics["generateReport"]>
  capability_ids: string[]
}

export class RegistryOperatorInspection {

  private readSurface: RegistryReadSurface
  private diagnostics: RegistryVisibilityDiagnostics
  private summary: RegistrySummarySurface

  constructor(
    readSurface: RegistryReadSurface,
    diagnostics: RegistryVisibilityDiagnostics,
    summary: RegistrySummarySurface
  ) {
    this.readSurface = readSurface
    this.diagnostics = diagnostics
    this.summary = summary
  }

  generateInspectionReport(): RegistryOperatorInspectionReport {

    const capabilities =
      this.readSurface.listCapabilities()

    return {

      summary: this.summary.generateSummary(),

      diagnostics: this.diagnostics.generateReport(),

      capability_ids:
        capabilities.map(c => c.capability_id)

    }

  }

}
