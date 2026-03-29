function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorCatalogHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator catalog: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorCatalogDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorCatalogSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorCatalogReadiness(
  ready: boolean,
): string {
  return `Catalog ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorCatalogCompleteness(
  complete: boolean,
): string {
  return `Catalog complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorCatalogVersion(
  version: string,
): string {
  return `Catalog version: ${version}`;
}
