export interface GovernanceDigestLine {
  key: string;
  text: string;
}

export interface GovernanceDigestRecord {
  decision_id: string;
  headline: string;
  lines: GovernanceDigestLine[];
  timestamp: number;
}
