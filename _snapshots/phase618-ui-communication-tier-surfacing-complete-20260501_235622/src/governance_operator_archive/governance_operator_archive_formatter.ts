function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorArchiveHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator archive: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorArchiveDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorArchiveSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorArchiveReadiness(
  ready: boolean,
): string {
  return `Archive ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorArchiveCompleteness(
  complete: boolean,
): string {
  return `Archive complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorArchiveVersion(
  version: string,
): string {
  return `Archive version: ${version}`;
}
