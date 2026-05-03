function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorExportHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator export: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorExportDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorExportSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorExportReadiness(
  ready: boolean,
): string {
  return `Export ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorExportCompleteness(
  complete: boolean,
): string {
  return `Export complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorExportVersion(
  version: string,
): string {
  return `Export version: ${version}`;
}
