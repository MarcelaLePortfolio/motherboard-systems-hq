function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorRecordHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator record: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorRecordDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorRecordSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorRecordReadiness(
  ready: boolean,
): string {
  return `Record ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorRecordCompleteness(
  complete: boolean,
): string {
  return `Record complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorRecordVersion(
  version: string,
): string {
  return `Record version: ${version}`;
}
