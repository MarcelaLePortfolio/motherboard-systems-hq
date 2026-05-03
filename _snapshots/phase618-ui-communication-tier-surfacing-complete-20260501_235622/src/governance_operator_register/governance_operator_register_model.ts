export interface GovernanceOperatorRegisterLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorRegisterMetadata {
  decision_id: string;
  register_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorRegisterRecord {
  headline: string;
  metadata: GovernanceOperatorRegisterMetadata;
  lines: GovernanceOperatorRegisterLine[];
}
