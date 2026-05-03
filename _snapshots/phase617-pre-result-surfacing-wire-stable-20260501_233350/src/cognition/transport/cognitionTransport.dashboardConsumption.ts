import {
  DashboardConsumptionAdapter,
  DashboardConsumptionContract,
  DashboardConsumptionEntry,
  DashboardConsumptionMapper
} from "./cognitionTransport.dashboardConsumption.types";

function toEntries(
  payload: Readonly<Record<string, unknown>>
): readonly DashboardConsumptionEntry[] {
  const keys = Object.keys(payload).sort();

  return keys.map((key) => ({
    key,
    value: payload[key] as DashboardConsumptionEntry["value"]
  }));
}

export const mapDashboardContractToConsumption: DashboardConsumptionMapper = (
  contract: DashboardConsumptionContract
): DashboardConsumptionAdapter => {
  const entries = toEntries(contract.payload);

  return {
    contractId: contract.contractId,
    section: contract.section,
    entries
  };
};

export function assertDashboardConsumptionDeterminism(
  contract: DashboardConsumptionContract
): void {
  const keys = Object.keys(contract.payload);
  const sorted = [...keys].sort();

  for (let i = 0; i < keys.length; i++) {
    if (sorted[i] !== sorted[i]) {
      throw new Error("Dashboard consumption key ordering invariant violated");
    }
  }
}
