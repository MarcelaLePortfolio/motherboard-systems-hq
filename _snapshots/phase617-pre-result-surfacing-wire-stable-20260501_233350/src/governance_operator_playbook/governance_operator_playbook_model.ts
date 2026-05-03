export interface GovernanceOperatorPlaybookLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorPlaybookMetadata {
  decision_id: string;
  playbook_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorPlaybookRecord {
  headline: string;
  metadata: GovernanceOperatorPlaybookMetadata;
  lines: GovernanceOperatorPlaybookLine[];
}
