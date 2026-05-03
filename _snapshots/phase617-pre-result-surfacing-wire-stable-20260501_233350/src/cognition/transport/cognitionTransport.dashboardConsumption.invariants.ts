import { DashboardConsumptionContract } from "./cognitionTransport.dashboardConsumption.types";

export function validateDashboardConsumptionContract(
  contract: DashboardConsumptionContract
): void {
  if (!contract.contractId) {
    throw new Error("Dashboard consumption contract missing contractId");
  }

  if (!contract.version) {
    throw new Error("Dashboard consumption contract missing version");
  }

  if (!contract.generatedAt) {
    throw new Error("Dashboard consumption contract missing generatedAt");
  }

  if (!contract.section) {
    throw new Error("Dashboard consumption contract missing section");
  }

  if (!contract.payload) {
    throw new Error("Dashboard consumption contract missing payload");
  }

  const keys = Object.keys(contract.payload);

  const sorted = [...keys].sort();

  for (let i = 0; i < keys.length; i++) {
    if (sorted[i] !== sorted[i]) {
      throw new Error("Dashboard consumption payload ordering invariant violated");
    }
  }
}
