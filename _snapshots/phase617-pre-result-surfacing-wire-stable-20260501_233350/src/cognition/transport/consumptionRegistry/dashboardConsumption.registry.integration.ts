import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

import {
  buildValidatedDashboardConsumptionRegistry
} from "./dashboardConsumption.registry.pipeline";

export let DASHBOARD_CONSUMPTION_REGISTRY:
  readonly DashboardConsumptionRegistryEntry[] = Object.freeze([]);

export function initializeDashboardConsumptionRegistry(
  entries: readonly DashboardConsumptionRegistryEntry[]
): void {

  DASHBOARD_CONSUMPTION_REGISTRY =
    buildValidatedDashboardConsumptionRegistry(entries);

}
