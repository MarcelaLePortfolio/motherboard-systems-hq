export interface GovernanceOperatorRecordLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorRecordMetadata {
  decision_id: string;
  record_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorRecordRecord {
  headline: string;
  metadata: GovernanceOperatorRecordMetadata;
  lines: GovernanceOperatorRecordLine[];
}
