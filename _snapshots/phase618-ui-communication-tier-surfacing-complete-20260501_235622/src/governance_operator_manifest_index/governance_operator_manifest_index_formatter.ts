function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorManifestIndexHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator manifest index: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorManifestIndexDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorManifestIndexSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorManifestIndexReadiness(
  ready: boolean,
): string {
  return `Manifest index ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorManifestIndexCompleteness(
  complete: boolean,
): string {
  return `Manifest index complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorManifestIndexVersion(
  version: string,
): string {
  return `Manifest index version: ${version}`;
}
