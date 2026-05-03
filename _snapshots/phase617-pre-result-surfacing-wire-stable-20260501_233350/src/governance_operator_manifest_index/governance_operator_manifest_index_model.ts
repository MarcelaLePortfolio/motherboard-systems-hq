export interface GovernanceOperatorManifestIndexLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorManifestIndexMetadata {
  decision_id: string;
  manifest_index_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorManifestIndexRecord {
  headline: string;
  metadata: GovernanceOperatorManifestIndexMetadata;
  lines: GovernanceOperatorManifestIndexLine[];
}
