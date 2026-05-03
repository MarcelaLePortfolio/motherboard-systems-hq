function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorManifestHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator manifest: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorManifestDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorManifestSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorManifestReadiness(
  ready: boolean,
): string {
  return `Manifest ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorManifestCompleteness(
  complete: boolean,
): string {
  return `Manifest complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorManifestVersion(
  version: string,
): string {
  return `Manifest version: ${version}`;
}
