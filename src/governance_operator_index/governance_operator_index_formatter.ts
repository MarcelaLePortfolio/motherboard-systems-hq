function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorIndexHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator index: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorIndexDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorIndexSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorIndexReadiness(
  ready: boolean,
): string {
  return `Index ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorIndexCompleteness(
  complete: boolean,
): string {
  return `Index complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorIndexVersion(
  version: string,
): string {
  return `Index version: ${version}`;
}
