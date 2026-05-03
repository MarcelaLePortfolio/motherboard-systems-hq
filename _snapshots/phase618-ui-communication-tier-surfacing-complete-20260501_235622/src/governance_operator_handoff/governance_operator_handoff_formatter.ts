function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorHandoffHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator handoff: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorHandoffDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorHandoffSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorHandoffReadiness(
  ready: boolean,
): string {
  return `Handoff ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorHandoffCompleteness(
  complete: boolean,
): string {
  return `Handoff complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorHandoffVersion(
  version: string,
): string {
  return `Handoff version: ${version}`;
}
