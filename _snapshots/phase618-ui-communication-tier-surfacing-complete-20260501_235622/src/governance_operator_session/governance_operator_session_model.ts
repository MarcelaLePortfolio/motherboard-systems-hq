export interface GovernanceOperatorSessionLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorSessionMetadata {
  decision_id: string;
  session_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorSessionRecord {
  headline: string;
  metadata: GovernanceOperatorSessionMetadata;
  lines: GovernanceOperatorSessionLine[];
}
