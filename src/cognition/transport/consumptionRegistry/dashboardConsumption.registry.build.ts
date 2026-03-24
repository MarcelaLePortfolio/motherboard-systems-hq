import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

import {
  freezeDashboardConsumptionRegistry
} from "./dashboardConsumption.registry.freeze";

export function buildDashboardConsumptionRegistry(
  entries: readonly DashboardConsumptionRegistryEntry[]
): readonly DashboardConsumptionRegistryEntry[] {

  return freezeDashboardConsumptionRegistry(entries);

}
