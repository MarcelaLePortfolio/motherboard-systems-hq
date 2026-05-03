function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorBriefingHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator briefing: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorBriefingDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorBriefingSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorBriefingReadiness(
  ready: boolean,
): string {
  return `Briefing ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorBriefingCompleteness(
  complete: boolean,
): string {
  return `Briefing complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorBriefingVersion(
  version: string,
): string {
  return `Briefing version: ${version}`;
}
