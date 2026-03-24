export interface DashboardConsumptionRegistryEntry {
  readonly contractId: string;
  readonly adapterId: string;
  readonly version: string;
  readonly section: string;
}

export interface DashboardConsumptionRegistry {
  readonly entries: readonly DashboardConsumptionRegistryEntry[];
}

export type DashboardConsumptionRegistryLookup = (
  contractId: string
) => DashboardConsumptionRegistryEntry | undefined;
