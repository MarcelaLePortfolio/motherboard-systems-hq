/*
Phase 151M — Registry Operator CLI Inspection Command

Purpose:
Provide a deterministic CLI command allowing operators to inspect
registry state safely.

Read-only command.

NO mutation permitted.
*/

import { RegistryStateStore } from "../../governance/registry/registry_state_store"
import { RegistryReadSurface } from "../../governance/registry/registry_read_surface"
import { RegistryVisibilityDiagnostics } from "../../governance/registry/registry_visibility_diagnostics"
import { RegistrySummarySurface } from "../../governance/registry/registry_summary_surface"
import { RegistryOperatorInspection } from "../../governance/registry/registry_operator_inspection"

function main() {

  // NOTE:
  // In later phases this should be wired to the real container.
  // For now we instantiate deterministic surfaces.

  const stateStore = new RegistryStateStore()

  const readSurface =
    new RegistryReadSurface(stateStore)

  const diagnostics =
    new RegistryVisibilityDiagnostics(readSurface)

  const summary =
    new RegistrySummarySurface(
      readSurface,
      diagnostics
    )

  const inspection =
    new RegistryOperatorInspection(
      readSurface,
      diagnostics,
      summary
    )

  const report =
    inspection.generateInspectionReport()

  console.log(
    JSON.stringify(report, null, 2)
  )

}

main()
