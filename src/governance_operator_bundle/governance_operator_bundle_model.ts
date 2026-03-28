export interface GovernanceOperatorBundleLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorBundleMetadata {
  decision_id: string;
  bundle_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorBundleRecord {
  headline: string;
  metadata: GovernanceOperatorBundleMetadata;
  lines: GovernanceOperatorBundleLine[];
}
