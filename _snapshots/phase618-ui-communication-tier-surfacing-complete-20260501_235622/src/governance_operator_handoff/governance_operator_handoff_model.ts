export interface GovernanceOperatorHandoffLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorHandoffMetadata {
  decision_id: string;
  handoff_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorHandoffRecord {
  headline: string;
  metadata: GovernanceOperatorHandoffMetadata;
  lines: GovernanceOperatorHandoffLine[];
}
