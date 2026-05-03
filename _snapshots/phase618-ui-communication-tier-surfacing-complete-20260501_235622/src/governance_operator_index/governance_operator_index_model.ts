export interface GovernanceOperatorIndexLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorIndexMetadata {
  decision_id: string;
  index_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorIndexRecord {
  headline: string;
  metadata: GovernanceOperatorIndexMetadata;
  lines: GovernanceOperatorIndexLine[];
}
