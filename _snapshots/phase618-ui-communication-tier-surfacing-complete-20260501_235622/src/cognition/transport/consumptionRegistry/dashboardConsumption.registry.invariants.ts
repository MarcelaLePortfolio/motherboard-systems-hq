import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

export function validateDashboardConsumptionRegistryEntry(
  entry: DashboardConsumptionRegistryEntry
): void {

  if (!entry.contractId) {
    throw new Error("Registry entry missing contractId");
  }

  if (!entry.adapterId) {
    throw new Error("Registry entry missing adapterId");
  }

  if (!entry.version) {
    throw new Error("Registry entry missing version");
  }

  if (!entry.section) {
    throw new Error("Registry entry missing section");
  }

}

export function assertRegistryDeterminism(
  entries: readonly DashboardConsumptionRegistryEntry[]
): void {

  const ids = entries.map(e => e.contractId);
  const sorted = [...ids].sort();

  for (let i = 0; i < ids.length; i++) {
    if (ids[i] !== sorted[i]) {
      throw new Error("Registry ordering invariant violated");
    }
  }

}
