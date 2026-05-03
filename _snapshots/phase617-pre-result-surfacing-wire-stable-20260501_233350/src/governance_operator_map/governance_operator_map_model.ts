export interface GovernanceOperatorMapLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorMapMetadata {
  decision_id: string;
  map_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorMapRecord {
  headline: string;
  metadata: GovernanceOperatorMapMetadata;
  lines: GovernanceOperatorMapLine[];
}
