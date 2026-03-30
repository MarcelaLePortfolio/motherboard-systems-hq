export interface GovernanceOperatorDictionaryLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorDictionaryMetadata {
  dictionary_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorDictionaryRecord {
  headline: string;
  metadata: GovernanceOperatorDictionaryMetadata;
  lines: GovernanceOperatorDictionaryLine[];
}
