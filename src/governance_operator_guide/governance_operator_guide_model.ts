export interface GovernanceOperatorGuideLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorGuideMetadata {
  decision_id: string;
  guide_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorGuideRecord {
  headline: string;
  metadata: GovernanceOperatorGuideMetadata;
  lines: GovernanceOperatorGuideLine[];
}
