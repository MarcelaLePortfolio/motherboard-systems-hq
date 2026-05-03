function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorLogbookHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator logbook: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorLogbookDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorLogbookSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorLogbookReadiness(
  ready: boolean,
): string {
  return `Logbook ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorLogbookCompleteness(
  complete: boolean,
): string {
  return `Logbook complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorLogbookVersion(
  version: string,
): string {
  return `Logbook version: ${version}`;
}
