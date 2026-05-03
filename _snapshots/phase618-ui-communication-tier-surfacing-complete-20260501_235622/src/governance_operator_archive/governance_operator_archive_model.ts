export interface GovernanceOperatorArchiveLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorArchiveMetadata {
  decision_id: string;
  archive_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorArchiveRecord {
  headline: string;
  metadata: GovernanceOperatorArchiveMetadata;
  lines: GovernanceOperatorArchiveLine[];
}
