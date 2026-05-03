export interface GovernanceOperatorConsoleLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorConsoleMetadata {
  decision_id: string;
  console_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorConsoleRecord {
  headline: string;
  metadata: GovernanceOperatorConsoleMetadata;
  lines: GovernanceOperatorConsoleLine[];
}
