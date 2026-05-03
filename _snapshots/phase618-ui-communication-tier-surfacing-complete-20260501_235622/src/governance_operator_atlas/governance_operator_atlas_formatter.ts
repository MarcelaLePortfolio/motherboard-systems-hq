function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorAtlasHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator atlas: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorAtlasDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorAtlasSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorAtlasReadiness(
  ready: boolean,
): string {
  return `Atlas ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorAtlasCompleteness(
  complete: boolean,
): string {
  return `Atlas complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorAtlasVersion(
  version: string,
): string {
  return `Atlas version: ${version}`;
}
