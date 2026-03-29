function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorMapHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator map: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorMapDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorMapSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorMapReadiness(
  ready: boolean,
): string {
  return `Map ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorMapCompleteness(
  complete: boolean,
): string {
  return `Map complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorMapVersion(
  version: string,
): string {
  return `Map version: ${version}`;
}
