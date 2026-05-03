function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorConsoleHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator console: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorConsoleDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorConsoleSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorConsoleReadiness(
  ready: boolean,
): string {
  return `Console ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorConsoleCompleteness(
  complete: boolean,
): string {
  return `Console complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorConsoleVersion(
  version: string,
): string {
  return `Console version: ${version}`;
}
