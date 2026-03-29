function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorRegistryHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator registry: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorRegistryDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorRegistrySections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorRegistryReadiness(
  ready: boolean,
): string {
  return `Registry ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorRegistryCompleteness(
  complete: boolean,
): string {
  return `Registry complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorRegistryVersion(
  version: string,
): string {
  return `Registry version: ${version}`;
}
