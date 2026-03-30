export interface GovernanceOperatorCompendiumLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorCompendiumMetadata {
  decision_id: string;
  compendium_version: string;
  ready: boolean;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorCompendiumRecord {
  headline: string;
  metadata: GovernanceOperatorCompendiumMetadata;
  lines: GovernanceOperatorCompendiumLine[];
}
