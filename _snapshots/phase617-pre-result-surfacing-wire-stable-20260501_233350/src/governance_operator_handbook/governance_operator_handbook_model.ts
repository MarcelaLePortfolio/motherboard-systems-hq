export interface GovernanceOperatorHandbookLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorHandbookMetadata {
  decision_id: string;
  handbook_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorHandbookRecord {
  headline: string;
  metadata: GovernanceOperatorHandbookMetadata;
  lines: GovernanceOperatorHandbookLine[];
}
