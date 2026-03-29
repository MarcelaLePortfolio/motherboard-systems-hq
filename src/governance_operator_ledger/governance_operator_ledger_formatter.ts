function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorLedgerHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator ledger: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorLedgerDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorLedgerSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorLedgerReadiness(
  ready: boolean,
): string {
  return `Ledger ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorLedgerCompleteness(
  complete: boolean,
): string {
  return `Ledger complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorLedgerVersion(
  version: string,
): string {
  return `Ledger version: ${version}`;
}
