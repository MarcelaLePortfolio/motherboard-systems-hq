function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorBundleHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator bundle: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorBundleDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorBundleSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorBundleReadiness(
  ready: boolean,
): string {
  return `Bundle ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorBundleCompleteness(
  complete: boolean,
): string {
  return `Bundle complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorBundleVersion(
  version: string,
): string {
  return `Bundle version: ${version}`;
}
