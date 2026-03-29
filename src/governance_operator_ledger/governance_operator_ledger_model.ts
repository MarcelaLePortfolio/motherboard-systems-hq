export interface GovernanceOperatorLedgerLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorLedgerMetadata {
  decision_id: string;
  ledger_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorLedgerRecord {
  headline: string;
  metadata: GovernanceOperatorLedgerMetadata;
  lines: GovernanceOperatorLedgerLine[];
}
