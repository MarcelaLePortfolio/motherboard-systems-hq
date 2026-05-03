import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

export function assertNoDuplicateContracts(
  entries: readonly DashboardConsumptionRegistryEntry[]
): void {

  const seen = new Set<string>();

  for (const entry of entries) {

    if (seen.has(entry.contractId)) {
      throw new Error(
        "Duplicate dashboard consumption contractId: " + entry.contractId
      );
    }

    seen.add(entry.contractId);

  }

}
