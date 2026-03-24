import {
  buildConsumptionRegistryOwnershipKey,
  enforceConsumptionRegistryOwnership,
  type ConsumptionRegistryEnforcementReport,
  type ConsumptionRegistryOwnershipEntry,
  type ConsumptionRegistryOwnershipIssue,
} from "./consumption_registry_enforcement";

export interface ConsumptionRegistryEnforcementValidationResult {
  ok: boolean;
  report: ConsumptionRegistryEnforcementReport;
  errorCount: number;
  errors: ReadonlyArray<string>;
}

function normalizeValue(value: string | null | undefined): string {
  return typeof value === "string" ? value.trim() : "";
}

function sortEntries(
  entries: ReadonlyArray<ConsumptionRegistryOwnershipEntry>,
): ConsumptionRegistryOwnershipEntry[] {
  return [...entries].sort((left, right) => {
    const leftKey = buildConsumptionRegistryOwnershipKey(left);
    const rightKey = buildConsumptionRegistryOwnershipKey(right);

    if (leftKey !== rightKey) {
      return leftKey.localeCompare(rightKey);
    }

    return normalizeValue(left.ownerId).localeCompare(normalizeValue(right.ownerId));
  });
}

function renderIssue(issue: ConsumptionRegistryOwnershipIssue): string {
  const renderedEntries = sortEntries(issue.entries)
    .map((entry) => {
      const contractId = normalizeValue(entry.contractId) || "<missing-contract>";
      const sectionKey = normalizeValue(entry.sectionKey) || "<missing-section>";
      const consumerId = normalizeValue(entry.consumerId) || "<missing-consumer>";
      const ownerId = normalizeValue(entry.ownerId) || "<missing-owner>";
      const source = normalizeValue(entry.source) || "<missing-source>";

      return `${contractId}/${sectionKey}/${consumerId}/${ownerId}/${source}`;
    })
    .join(", ");

  return `[${issue.kind}] ${issue.key} :: ${issue.message} :: entries=${renderedEntries}`;
}

export function validateConsumptionRegistryEnforcement(
  entries: ReadonlyArray<ConsumptionRegistryOwnershipEntry>,
): ConsumptionRegistryEnforcementValidationResult {
  const report = enforceConsumptionRegistryOwnership(entries);
  const errors = report.issues.map(renderIssue);

  return {
    ok: report.ok,
    report,
    errorCount: errors.length,
    errors,
  };
}
