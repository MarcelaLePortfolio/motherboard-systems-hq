export interface GovernanceOperatorLexiconLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorLexiconMetadata {
  lexicon_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorLexiconRecord {
  headline: string;
  metadata: GovernanceOperatorLexiconMetadata;
  lines: GovernanceOperatorLexiconLine[];
}
