export interface GovernanceOperatorAtlasLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorAtlasMetadata {
  decision_id: string;
  atlas_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorAtlasRecord {
  headline: string;
  metadata: GovernanceOperatorAtlasMetadata;
  lines: GovernanceOperatorAtlasLine[];
}
