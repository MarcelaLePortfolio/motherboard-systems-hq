export interface GovernanceReportLine {
  label: string;
  value: string;
}

export interface GovernanceReportSection {
  title: string;
  lines: GovernanceReportLine[];
}

export interface GovernanceReportRecord {
  decision_id: string;
  headline: string;
  sections: GovernanceReportSection[];
  timestamp: number;
}
