import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

import {
  buildValidatedDashboardConsumptionRegistry
} from "./dashboardConsumption.registry.pipeline";

/*
Single runtime source of truth.
No secondary mutable registry allowed.
Deterministic replacement only.
*/

let registry:
  readonly DashboardConsumptionRegistryEntry[] = Object.freeze([]);

export function setDashboardConsumptionRegistry(
  entries: readonly DashboardConsumptionRegistryEntry[]
): void {

  registry =
    buildValidatedDashboardConsumptionRegistry(entries);

}

export function getDashboardConsumptionRegistry():
  readonly DashboardConsumptionRegistryEntry[] {

  return registry;

}
