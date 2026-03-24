import {
  mapDashboardContractToConsumption
} from "./cognitionTransport.dashboardConsumption";

import {
  validateDashboardConsumptionContract
} from "./cognitionTransport.dashboardConsumption.invariants";

import {
  DashboardConsumptionContract
} from "./cognitionTransport.dashboardConsumption.types";

function deepFreeze<T>(obj: T): T {
  Object.freeze(obj);

  Object.getOwnPropertyNames(obj as object).forEach((prop) => {
    const value = (obj as any)[prop];

    if (
      value !== null &&
      (typeof value === "object" || typeof value === "function") &&
      !Object.isFrozen(value)
    ) {
      deepFreeze(value);
    }
  });

  return obj;
}

const contract: DashboardConsumptionContract = deepFreeze({
  contractId: "test.contract",
  version: "1",
  generatedAt: "deterministic",
  source: "test",
  section: "dashboard",
  payload: {
    zeta: 1,
    alpha: 2,
    beta: 3
  }
});

validateDashboardConsumptionContract(contract);

const result = mapDashboardContractToConsumption(contract);

if (result.entries[0].key !== "alpha") {
  throw new Error("Deterministic ordering failed");
}

if (result.entries[1].key !== "beta") {
  throw new Error("Deterministic ordering failed");
}

if (result.entries[2].key !== "zeta") {
  throw new Error("Deterministic ordering failed");
}

if (Object.isFrozen(contract) !== true) {
  throw new Error("Contract must remain immutable");
}

console.log("phase120 dashboard consumption deterministic test passed");
