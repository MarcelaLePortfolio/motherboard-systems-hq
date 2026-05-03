function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorDirectoryHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator directory: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorDirectoryDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorDirectorySections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorDirectoryReadiness(
  ready: boolean,
): string {
  return `Directory ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorDirectoryCompleteness(
  complete: boolean,
): string {
  return `Directory complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorDirectoryVersion(
  version: string,
): string {
  return `Directory version: ${version}`;
}
