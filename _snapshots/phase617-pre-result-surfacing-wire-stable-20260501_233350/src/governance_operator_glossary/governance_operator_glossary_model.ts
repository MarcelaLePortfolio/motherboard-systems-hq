export interface GovernanceOperatorGlossaryLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorGlossaryMetadata {
  glossary_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorGlossaryRecord {
  headline: string;
  metadata: GovernanceOperatorGlossaryMetadata;
  lines: GovernanceOperatorGlossaryLine[];
}
