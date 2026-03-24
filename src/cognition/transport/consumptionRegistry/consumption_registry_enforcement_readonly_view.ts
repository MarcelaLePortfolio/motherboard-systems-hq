import {
  runConsumptionRegistryEnforcementRuntimeGuard,
  type ConsumptionRegistryEnforcementRuntimeGuardResult,
} from "./consumption_registry_enforcement_runtime_guard";

export interface ConsumptionRegistryEnforcementReadonlyView {
  ok: boolean;
  lines: ReadonlyArray<string>;
}

function sortLines(lines: ReadonlyArray<string>): string[] {
  return [...lines].sort((left, right) => left.localeCompare(right));
}

export function createConsumptionRegistryEnforcementReadonlyView(): ConsumptionRegistryEnforcementReadonlyView {
  const runtimeGuard: ConsumptionRegistryEnforcementRuntimeGuardResult =
    runConsumptionRegistryEnforcementRuntimeGuard();

  const lines = sortLines([
    `ok=${runtimeGuard.ok}`,
    `message=${runtimeGuard.message}`,
    `bundle.ok=${runtimeGuard.bundle.ok}`,
    `validation.ok=${runtimeGuard.bundle.validation.ok}`,
    `report.ok=${runtimeGuard.bundle.report.summary.ok}`,
    `snapshot.ok=${runtimeGuard.bundle.snapshot.ok}`,
    `errorCount=${runtimeGuard.bundle.validation.errorCount}`,
    `ownershipKeyCount=${runtimeGuard.bundle.report.summary.ownershipKeyCount}`,
    `missingConsumerCount=${runtimeGuard.bundle.report.summary.missingConsumerCount}`,
    `duplicateOwnershipCount=${runtimeGuard.bundle.report.summary.duplicateOwnershipCount}`,
  ]);

  return {
    ok: runtimeGuard.ok,
    lines,
  };
}
