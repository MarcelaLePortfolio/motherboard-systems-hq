export interface GovernanceOperatorManualLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorManualMetadata {
  decision_id: string;
  manual_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorManualRecord {
  headline: string;
  metadata: GovernanceOperatorManualMetadata;
  lines: GovernanceOperatorManualLine[];
}
