export interface GovernanceOperatorManifestEntry {
  key: string;
  text: string;
}

export interface GovernanceOperatorManifestMetadata {
  decision_id: string;
  manifest_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorManifestRecord {
  headline: string;
  metadata: GovernanceOperatorManifestMetadata;
  entries: GovernanceOperatorManifestEntry[];
}
