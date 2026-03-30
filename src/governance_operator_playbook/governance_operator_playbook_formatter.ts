function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorPlaybookHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator playbook: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorPlaybookDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorPlaybookSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorPlaybookReadiness(
  ready: boolean,
): string {
  return `Playbook ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorPlaybookCompleteness(
  complete: boolean,
): string {
  return `Playbook complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorPlaybookVersion(
  version: string,
): string {
  return `Playbook version: ${version}`;
}
