function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorReferenceHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator reference: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorReferenceDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorReferenceSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorReferenceReadiness(
  ready: boolean,
): string {
  return `Reference ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorReferenceCompleteness(
  complete: boolean,
): string {
  return `Reference complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorReferenceVersion(
  version: string,
): string {
  return `Reference version: ${version}`;
}
