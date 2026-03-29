export interface GovernanceOperatorCatalogLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorCatalogMetadata {
  decision_id: string;
  catalog_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorCatalogRecord {
  headline: string;
  metadata: GovernanceOperatorCatalogMetadata;
  lines: GovernanceOperatorCatalogLine[];
}
