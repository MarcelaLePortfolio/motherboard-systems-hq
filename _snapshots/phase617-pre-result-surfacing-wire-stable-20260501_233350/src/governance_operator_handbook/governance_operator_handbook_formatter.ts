function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorHandbookHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator handbook: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorHandbookDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorHandbookSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorHandbookReadiness(
  ready: boolean,
): string {
  return `Handbook ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorHandbookCompleteness(
  complete: boolean,
): string {
  return `Handbook complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorHandbookVersion(
  version: string,
): string {
  return `Handbook version: ${version}`;
}
