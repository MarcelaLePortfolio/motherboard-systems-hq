import type {
  GovernanceOperatorLedgerLine,
  GovernanceOperatorLedgerRecord,
} from "./governance_operator_ledger_model";
import {
  formatGovernanceOperatorLedgerCompleteness,
  formatGovernanceOperatorLedgerDecision,
  formatGovernanceOperatorLedgerHeadline,
  formatGovernanceOperatorLedgerReadiness,
  formatGovernanceOperatorLedgerSections,
  formatGovernanceOperatorLedgerVersion,
} from "./governance_operator_ledger_formatter";

export interface GovernanceOperatorLedgerInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorLedger(
  input: GovernanceOperatorLedgerInput,
): GovernanceOperatorLedgerRecord {
  const ready = true;
  const complete = true;
  const ledgerVersion = "1";

  const lines: GovernanceOperatorLedgerLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorLedgerDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorLedgerSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorLedgerReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorLedgerCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorLedgerVersion(ledgerVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorLedgerHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      ledger_version: ledgerVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
