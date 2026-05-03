export interface GovernanceOperatorPacketLine {
  key: string;
  text: string;
}

export interface GovernanceOperatorPacketSection {
  title: string;
  lines: GovernanceOperatorPacketLine[];
}

export interface GovernanceOperatorPacketMetadata {
  decision_id: string;
  packet_version: string;
  complete: boolean;
  timestamp: number;
}

export interface GovernanceOperatorPacketRecord {
  headline: string;
  metadata: GovernanceOperatorPacketMetadata;
  sections: GovernanceOperatorPacketSection[];
}
