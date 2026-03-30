function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorGuideHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator guide: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorGuideDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorGuideSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorGuideReadiness(
  ready: boolean,
): string {
  return `Guide ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorGuideCompleteness(
  complete: boolean,
): string {
  return `Guide complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorGuideVersion(
  version: string,
): string {
  return `Guide version: ${version}`;
}
