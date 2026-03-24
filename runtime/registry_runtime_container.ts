/*
PHASE 154 — RUNTIME CONTAINER SKELETON IMPLEMENTATION

STATUS: SKELETON IMPLEMENTED
DATE: 2026-03-24

SAFETY RULES:

No mutation logic added
No business logic added
No diagnostics logic added
No workflow logic added

Structure only.
*/

import { RegistryStateStore } from "../governance/registry/registry_state_store"
import { RegistryMutationCoordinator } from "../governance/registry/registry_mutation_coordinator"
import { RegistryOwnerSurface } from "../governance/registry/registry_owner_surface"

import { RegistryReadSurface } from "../governance/registry/registry_read_surface"
import { RegistryVisibilityDiagnostics } from "../governance/registry/registry_visibility_diagnostics"
import { RegistrySummarySurface } from "../governance/registry/registry_summary_surface"
import { RegistryOperatorInspection } from "../governance/registry/registry_operator_inspection"
import { RegistryWorkflowSurface } from "../governance/registry/registry_workflow_surface"

export class RegistryRuntimeContainer {

  private store: RegistryStateStore

  private mutationCoordinator: RegistryMutationCoordinator

  private ownerSurface: RegistryOwnerSurface

  private readSurface: RegistryReadSurface

  private diagnostics: RegistryVisibilityDiagnostics

  private summary: RegistrySummarySurface

  private inspection: RegistryOperatorInspection

  private workflow: RegistryWorkflowSurface


  constructor() {

    this.store =
      new RegistryStateStore()

    this.mutationCoordinator =
      new RegistryMutationCoordinator(
        this.store
      )

    this.ownerSurface =
      new RegistryOwnerSurface(
        this.mutationCoordinator
      )

    this.readSurface =
      new RegistryReadSurface(
        this.store
      )

    this.diagnostics =
      new RegistryVisibilityDiagnostics(
        this.readSurface
      )

    this.summary =
      new RegistrySummarySurface(
        this.readSurface,
        this.diagnostics
      )

    this.inspection =
      new RegistryOperatorInspection(
        this.readSurface,
        this.diagnostics,
        this.summary
      )

    this.workflow =
      new RegistryWorkflowSurface(
        this.inspection
      )

  }


  getRegistryInspectionSurface():
    RegistryOperatorInspection {

    return this.inspection

  }


  getRegistryWorkflowSurface():
    RegistryWorkflowSurface {

    return this.workflow

  }


  getRegistrySummarySurface():
    RegistrySummarySurface {

    return this.summary

  }

}

