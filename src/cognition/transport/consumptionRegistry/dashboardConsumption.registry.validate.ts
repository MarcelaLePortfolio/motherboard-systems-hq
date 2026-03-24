import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

import {
  validateDashboardConsumptionRegistryEntry,
  assertRegistryDeterminism
} from "./dashboardConsumption.registry.invariants";

export function validateDashboardConsumptionRegistry(
  entries: readonly DashboardConsumptionRegistryEntry[]
): void {

  for (const entry of entries) {
    validateDashboardConsumptionRegistryEntry(entry);
  }

  assertRegistryDeterminism(entries);

}
