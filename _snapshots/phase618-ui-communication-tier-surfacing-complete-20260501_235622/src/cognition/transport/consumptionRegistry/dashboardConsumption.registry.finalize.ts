import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

import {
  buildDashboardConsumptionRegistry
} from "./dashboardConsumption.registry.build";

import {
  assertConsumptionRegistryNotEmpty
} from "./dashboardConsumption.registry.guard";

export function finalizeDashboardConsumptionRegistry(
  entries: readonly DashboardConsumptionRegistryEntry[]
): readonly DashboardConsumptionRegistryEntry[] {

  const registry = buildDashboardConsumptionRegistry(entries);

  assertConsumptionRegistryNotEmpty(registry);

  return registry;

}
