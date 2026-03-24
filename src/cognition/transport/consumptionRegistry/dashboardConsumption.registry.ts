import {
  DashboardConsumptionRegistry,
  DashboardConsumptionRegistryEntry,
  DashboardConsumptionRegistryLookup
} from "./dashboardConsumption.registry.types";

const REGISTRY: DashboardConsumptionRegistry = {
  entries: []
};

export function registerDashboardConsumptionEntry(
  entry: DashboardConsumptionRegistryEntry
): DashboardConsumptionRegistry {
  const next: DashboardConsumptionRegistryEntry[] = [
    ...REGISTRY.entries,
    entry
  ].sort((a, b) => a.contractId.localeCompare(b.contractId));

  return {
    entries: next
  };
}

export const lookupDashboardConsumptionEntry: DashboardConsumptionRegistryLookup =
  (contractId) => {
    return REGISTRY.entries.find((e) => e.contractId === contractId);
  };

export function listDashboardConsumptionEntries():
  readonly DashboardConsumptionRegistryEntry[] {
  return [...REGISTRY.entries];
}
