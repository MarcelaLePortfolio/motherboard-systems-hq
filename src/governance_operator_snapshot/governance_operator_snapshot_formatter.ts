function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorSnapshotHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator snapshot: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorSnapshotDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorSnapshotSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorSnapshotReadiness(
  ready: boolean,
): string {
  return `Snapshot ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorSnapshotCompleteness(
  complete: boolean,
): string {
  return `Snapshot complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorSnapshotVersion(
  version: string,
): string {
  return `Snapshot version: ${version}`;
}
