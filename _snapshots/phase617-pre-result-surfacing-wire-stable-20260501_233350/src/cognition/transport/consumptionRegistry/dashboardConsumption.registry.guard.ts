import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

export function assertConsumptionRegistryNotEmpty(
  entries: readonly DashboardConsumptionRegistryEntry[]
): void {

  if (entries.length === 0) {
    throw new Error("Dashboard consumption registry cannot be empty");
  }

}
