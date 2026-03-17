import { RUNBOOK_CATALOG } from "./operatorRunbookCatalog";
import type { Runbook } from "./operatorRunbookTypes";

export type RunbookInput = {
  diagnosticsClean: boolean;
  driftDetected: boolean;
  structuralRisk: boolean;
};

export function resolveOperatorRunbook(input: RunbookInput): Runbook {
  if (input.structuralRisk) {
    return RUNBOOK_CATALOG.RUNBOOK_RECOVERY_FIRST;
  }

  if (input.driftDetected) {
    return RUNBOOK_CATALOG.RUNBOOK_INVESTIGATE_DRIFT;
  }

  if (!input.diagnosticsClean) {
    return RUNBOOK_CATALOG.RUNBOOK_OBSERVE_ONLY;
  }

  return RUNBOOK_CATALOG.RUNBOOK_STABLE_CONTINUE;
}
