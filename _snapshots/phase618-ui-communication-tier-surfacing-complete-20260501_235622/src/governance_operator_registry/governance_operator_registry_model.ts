export interface GovernanceOperatorRegistryLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorRegistryMetadata {
  decision_id: string;
  registry_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorRegistryRecord {
  headline: string;
  metadata: GovernanceOperatorRegistryMetadata;
  lines: GovernanceOperatorRegistryLine[];
}
