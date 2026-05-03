import {
  type ConsumptionRegistryOwnershipEntry,
} from "./consumption_registry_enforcement";
import {
  validateConsumptionRegistryEnforcement,
  type ConsumptionRegistryEnforcementValidationResult,
} from "./consumption_registry_enforcement_validation";
import {
  createConsumptionRegistryEnforcementReport,
  type ConsumptionRegistryEnforcementReportView,
} from "./consumption_registry_enforcement_report";

export interface ConsumptionRegistryEnforcementFixtureSet {
  validEntries: ReadonlyArray<ConsumptionRegistryOwnershipEntry>;
  invalidEntries: ReadonlyArray<ConsumptionRegistryOwnershipEntry>;
}

export interface ConsumptionRegistryEnforcementFixtureProof {
  valid: ConsumptionRegistryEnforcementValidationResult;
  invalid: ConsumptionRegistryEnforcementValidationResult;
  validReport: ConsumptionRegistryEnforcementReportView;
  invalidReport: ConsumptionRegistryEnforcementReportView;
}

export function createConsumptionRegistryEnforcementFixtureSet(): ConsumptionRegistryEnforcementFixtureSet {
  const validEntries: ReadonlyArray<ConsumptionRegistryOwnershipEntry> = [
    {
      contractId: "dashboard-contract",
      sectionKey: "overview",
      consumerId: "overview-panel",
      ownerId: "runtime-registry-owner",
      source: "fixture-valid-a",
    },
    {
      contractId: "dashboard-contract",
      sectionKey: "signals",
      consumerId: "signals-panel",
      ownerId: "runtime-registry-owner",
      source: "fixture-valid-b",
    },
  ];

  const invalidEntries: ReadonlyArray<ConsumptionRegistryOwnershipEntry> = [
    {
      contractId: "dashboard-contract",
      sectionKey: "overview",
      consumerId: "",
      ownerId: "runtime-registry-owner",
      source: "fixture-missing-consumer",
    },
    {
      contractId: "dashboard-contract",
      sectionKey: "signals",
      consumerId: "signals-panel",
      ownerId: "runtime-registry-owner-a",
      source: "fixture-duplicate-owner-a",
    },
    {
      contractId: "dashboard-contract",
      sectionKey: "signals",
      consumerId: "signals-panel",
      ownerId: "runtime-registry-owner-b",
      source: "fixture-duplicate-owner-b",
    },
  ];

  return {
    validEntries,
    invalidEntries,
  };
}

export function createConsumptionRegistryEnforcementFixtureProof(): ConsumptionRegistryEnforcementFixtureProof {
  const fixtures = createConsumptionRegistryEnforcementFixtureSet();

  const valid = validateConsumptionRegistryEnforcement(fixtures.validEntries);
  const invalid = validateConsumptionRegistryEnforcement(fixtures.invalidEntries);

  return {
    valid,
    invalid,
    validReport: createConsumptionRegistryEnforcementReport(valid),
    invalidReport: createConsumptionRegistryEnforcementReport(invalid),
  };
}
