import {
  createConsumptionRegistryEnforcementSnapshot,
  type ConsumptionRegistryEnforcementSnapshot,
} from "./consumption_registry_enforcement_snapshot";
import {
  createConsumptionRegistryEnforcementReport,
  type ConsumptionRegistryEnforcementReportView,
} from "./consumption_registry_enforcement_report";
import {
  validateConsumptionRegistryEnforcement,
  type ConsumptionRegistryEnforcementValidationResult,
} from "./consumption_registry_enforcement_validation";
import {
  createConsumptionRegistryEnforcementFixtureSet,
} from "./consumption_registry_enforcement_fixture";

export interface ConsumptionRegistryEnforcementBundle {
  ok: boolean;
  validation: ConsumptionRegistryEnforcementValidationResult;
  report: ConsumptionRegistryEnforcementReportView;
  snapshot: ConsumptionRegistryEnforcementSnapshot;
}

export function createConsumptionRegistryEnforcementBundle(): ConsumptionRegistryEnforcementBundle {
  const fixtures = createConsumptionRegistryEnforcementFixtureSet();
  const validation = validateConsumptionRegistryEnforcement(fixtures.validEntries);
  const report = createConsumptionRegistryEnforcementReport(validation);
  const snapshot = createConsumptionRegistryEnforcementSnapshot();

  return {
    ok: validation.ok && report.summary.ok && snapshot.ok,
    validation,
    report,
    snapshot,
  };
}
