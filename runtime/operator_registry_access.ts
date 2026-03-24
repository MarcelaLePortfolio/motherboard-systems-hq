/*
PHASE 161 — OPERATOR REGISTRY ACCESS HELPER IMPLEMENTATION

STATUS: IMPLEMENTED
DATE: 2026-03-24

SAFETY RULES:

No logic
No mutation
No routing
No execution
No caching

Access forwarding only.
*/

import { RuntimeBootstrap } from "./runtime_bootstrap"
import { RegistryOperatorInspection } from "../governance/registry/registry_operator_inspection"
import { RegistryWorkflowSurface } from "../governance/registry/registry_workflow_surface"
import { RegistrySummarySurface } from "../governance/registry/registry_summary_surface"

export function getRegistryInspection(
  runtime: RuntimeBootstrap
): RegistryOperatorInspection {

  return runtime
    .getServices()
    .registry
    .getRegistryInspectionSurface()

}

export function getRegistryWorkflow(
  runtime: RuntimeBootstrap
): RegistryWorkflowSurface {

  return runtime
    .getServices()
    .registry
    .getRegistryWorkflowSurface()

}

export function getRegistrySummary(
  runtime: RuntimeBootstrap
): RegistrySummarySurface {

  return runtime
    .getServices()
    .registry
    .getRegistrySummarySurface()

}

