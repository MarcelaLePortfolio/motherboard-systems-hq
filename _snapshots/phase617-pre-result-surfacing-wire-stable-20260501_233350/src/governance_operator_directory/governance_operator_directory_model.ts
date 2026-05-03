export interface GovernanceOperatorDirectoryLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorDirectoryMetadata {
  decision_id: string;
  directory_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorDirectoryRecord {
  headline: string;
  metadata: GovernanceOperatorDirectoryMetadata;
  lines: GovernanceOperatorDirectoryLine[];
}
