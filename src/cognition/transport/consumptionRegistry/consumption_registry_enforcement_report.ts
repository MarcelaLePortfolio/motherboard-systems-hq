import {
  type ConsumptionRegistryEnforcementValidationResult,
} from "./consumption_registry_enforcement_validation";

export interface ConsumptionRegistryEnforcementSummary {
  ok: boolean;
  errorCount: number;
  ownershipKeyCount: number;
  missingConsumerCount: number;
  duplicateOwnershipCount: number;
}

export interface ConsumptionRegistryEnforcementReportView {
  summary: ConsumptionRegistryEnforcementSummary;
  lines: ReadonlyArray<string>;
}

function sortLines(lines: ReadonlyArray<string>): string[] {
  return [...lines].sort((left, right) => left.localeCompare(right));
}

export function createConsumptionRegistryEnforcementReport(
  result: ConsumptionRegistryEnforcementValidationResult,
): ConsumptionRegistryEnforcementReportView {
  const summary: ConsumptionRegistryEnforcementSummary = {
    ok: result.ok,
    errorCount: result.errorCount,
    ownershipKeyCount: result.report.ownershipKeys.length,
    missingConsumerCount: result.report.missingConsumers.length,
    duplicateOwnershipCount: result.report.duplicateOwnerships.length,
  };

  const lines = sortLines([
    `ok=${summary.ok}`,
    `errorCount=${summary.errorCount}`,
    `ownershipKeyCount=${summary.ownershipKeyCount}`,
    `missingConsumerCount=${summary.missingConsumerCount}`,
    `duplicateOwnershipCount=${summary.duplicateOwnershipCount}`,
    ...result.errors.map((error, index) => `error[${index}]=${error}`),
  ]);

  return {
    summary,
    lines,
  };
}
