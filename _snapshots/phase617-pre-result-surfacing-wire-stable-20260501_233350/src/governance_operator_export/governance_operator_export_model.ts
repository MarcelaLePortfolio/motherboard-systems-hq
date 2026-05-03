export interface GovernanceOperatorExportLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorExportMetadata {
  decision_id: string;
  export_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorExportRecord {
  headline: string;
  metadata: GovernanceOperatorExportMetadata;
  lines: GovernanceOperatorExportLine[];
}
