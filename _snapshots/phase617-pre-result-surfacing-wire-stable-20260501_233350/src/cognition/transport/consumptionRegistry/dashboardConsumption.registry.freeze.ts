import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

import {
  validateDashboardConsumptionRegistry
} from "./dashboardConsumption.registry.validate";

export function freezeDashboardConsumptionRegistry(
  entries: readonly DashboardConsumptionRegistryEntry[]
): readonly DashboardConsumptionRegistryEntry[] {

  validateDashboardConsumptionRegistry(entries);

  return Object.freeze([...entries]);

}
