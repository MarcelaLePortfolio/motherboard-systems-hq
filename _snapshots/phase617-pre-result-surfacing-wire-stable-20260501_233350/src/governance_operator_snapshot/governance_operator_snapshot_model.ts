export interface GovernanceOperatorSnapshotLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorSnapshotMetadata {
  decision_id: string;
  snapshot_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorSnapshotRecord {
  headline: string;
  metadata: GovernanceOperatorSnapshotMetadata;
  lines: GovernanceOperatorSnapshotLine[];
}
