function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorRegisterHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator register: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorRegisterDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorRegisterSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorRegisterReadiness(
  ready: boolean,
): string {
  return `Register ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorRegisterCompleteness(
  complete: boolean,
): string {
  return `Register complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorRegisterVersion(
  version: string,
): string {
  return `Register version: ${version}`;
}
