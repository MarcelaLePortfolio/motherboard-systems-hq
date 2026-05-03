import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

import {
  finalizeDashboardConsumptionRegistry
} from "./dashboardConsumption.registry.finalize";

import {
  assertNoDuplicateContracts
} from "./dashboardConsumption.registry.integrity";

export function buildValidatedDashboardConsumptionRegistry(
  entries: readonly DashboardConsumptionRegistryEntry[]
): readonly DashboardConsumptionRegistryEntry[] {

  const registry = finalizeDashboardConsumptionRegistry(entries);

  assertNoDuplicateContracts(registry);

  return registry;

}
