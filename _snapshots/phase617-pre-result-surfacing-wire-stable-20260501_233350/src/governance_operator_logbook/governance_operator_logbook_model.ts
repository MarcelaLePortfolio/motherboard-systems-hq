export interface GovernanceOperatorLogbookLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorLogbookMetadata {
  decision_id: string;
  logbook_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorLogbookRecord {
  headline: string;
  metadata: GovernanceOperatorLogbookMetadata;
  lines: GovernanceOperatorLogbookLine[];
}
