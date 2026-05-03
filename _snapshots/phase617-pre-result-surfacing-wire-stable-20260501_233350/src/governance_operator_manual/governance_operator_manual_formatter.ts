function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorManualHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator manual: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorManualDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorManualSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorManualReadiness(
  ready: boolean,
): string {
  return `Manual ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorManualCompleteness(
  complete: boolean,
): string {
  return `Manual complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorManualVersion(
  version: string,
): string {
  return `Manual version: ${version}`;
}
