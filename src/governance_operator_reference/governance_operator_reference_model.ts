export interface GovernanceOperatorReferenceLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorReferenceMetadata {
  decision_id: string;
  reference_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorReferenceRecord {
  headline: string;
  metadata: GovernanceOperatorReferenceMetadata;
  lines: GovernanceOperatorReferenceLine[];
}
