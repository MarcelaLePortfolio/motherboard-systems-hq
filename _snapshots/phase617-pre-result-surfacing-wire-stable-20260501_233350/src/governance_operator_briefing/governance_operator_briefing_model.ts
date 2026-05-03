export interface GovernanceOperatorBriefingLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorBriefingMetadata {
  decision_id: string;
  briefing_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorBriefingRecord {
  headline: string;
  metadata: GovernanceOperatorBriefingMetadata;
  lines: GovernanceOperatorBriefingLine[];
}
