export type ConsumptionRegistryOwnershipIssueKind =
  | "missing-consumer"
  | "duplicate-ownership";

export interface ConsumptionRegistryOwnershipEntry {
  consumerId?: string | null;
  ownerId?: string | null;
  contractId?: string | null;
  sectionKey?: string | null;
  source?: string | null;
}

export interface ConsumptionRegistryOwnershipIssue {
  kind: ConsumptionRegistryOwnershipIssueKind;
  key: string;
  message: string;
  entries: ReadonlyArray<ConsumptionRegistryOwnershipEntry>;
}

export interface ConsumptionRegistryEnforcementReport {
  ok: boolean;
  ownershipKeys: ReadonlyArray<string>;
  missingConsumers: ReadonlyArray<ConsumptionRegistryOwnershipIssue>;
  duplicateOwnerships: ReadonlyArray<ConsumptionRegistryOwnershipIssue>;
  issues: ReadonlyArray<ConsumptionRegistryOwnershipIssue>;
}

function normalizeValue(value: string | null | undefined): string {
  return typeof value === "string" ? value.trim() : "";
}

export function buildConsumptionRegistryOwnershipKey(
  entry: ConsumptionRegistryOwnershipEntry,
): string {
  return [
    normalizeValue(entry.contractId),
    normalizeValue(entry.sectionKey),
    normalizeValue(entry.consumerId),
  ].join("::");
}

function hasConsumer(entry: ConsumptionRegistryOwnershipEntry): boolean {
  return normalizeValue(entry.consumerId).length > 0;
}

function hasOwner(entry: ConsumptionRegistryOwnershipEntry): boolean {
  return normalizeValue(entry.ownerId).length > 0;
}

function sortIssues(
  issues: ReadonlyArray<ConsumptionRegistryOwnershipIssue>,
): ConsumptionRegistryOwnershipIssue[] {
  return [...issues].sort((left, right) => {
    if (left.kind !== right.kind) {
      return left.kind.localeCompare(right.kind);
    }

    return left.key.localeCompare(right.key);
  });
}

export function enforceConsumptionRegistryOwnership(
  entries: ReadonlyArray<ConsumptionRegistryOwnershipEntry>,
): ConsumptionRegistryEnforcementReport {
  const missingConsumers: ConsumptionRegistryOwnershipIssue[] = [];
  const grouped = new Map<string, ConsumptionRegistryOwnershipEntry[]>();

  for (const entry of entries) {
    if (!hasConsumer(entry)) {
      missingConsumers.push({
        kind: "missing-consumer",
        key: buildConsumptionRegistryOwnershipKey(entry),
        message:
          "Consumption registry entry is missing a deterministic consumerId.",
        entries: [entry],
      });
      continue;
    }

    const key = buildConsumptionRegistryOwnershipKey(entry);
    const existing = grouped.get(key) ?? [];
    existing.push(entry);
    grouped.set(key, existing);
  }

  const duplicateOwnerships: ConsumptionRegistryOwnershipIssue[] = [];

  for (const [key, group] of grouped.entries()) {
    const owners = Array.from(
      new Set(group.map((entry) => normalizeValue(entry.ownerId)).filter(Boolean)),
    );

    if (owners.length > 1) {
      duplicateOwnerships.push({
        kind: "duplicate-ownership",
        key,
        message:
          "Consumption registry ownership is ambiguous. A single consumer key resolved to multiple owners.",
        entries: group,
      });
      continue;
    }

    if (owners.length === 0 || !group.every(hasOwner)) {
      duplicateOwnerships.push({
        kind: "duplicate-ownership",
        key,
        message:
          "Consumption registry ownership is incomplete. A deterministic ownerId is required for every consumer key.",
        entries: group,
      });
    }
  }

  const issues = sortIssues([...missingConsumers, ...duplicateOwnerships]);
  const ownershipKeys = Array.from(grouped.keys()).sort();

  return {
    ok: issues.length === 0,
    ownershipKeys,
    missingConsumers: sortIssues(missingConsumers),
    duplicateOwnerships: sortIssues(duplicateOwnerships),
    issues,
  };
}
