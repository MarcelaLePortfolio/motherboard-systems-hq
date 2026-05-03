import type {
  GovernanceOperatorExportLine,
  GovernanceOperatorExportRecord,
} from "./governance_operator_export_model";
import {
  formatGovernanceOperatorExportCompleteness,
  formatGovernanceOperatorExportDecision,
  formatGovernanceOperatorExportHeadline,
  formatGovernanceOperatorExportReadiness,
  formatGovernanceOperatorExportSections,
  formatGovernanceOperatorExportVersion,
} from "./governance_operator_export_formatter";

export interface GovernanceOperatorExportInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorExport(
  input: GovernanceOperatorExportInput,
): GovernanceOperatorExportRecord {
  const ready = true;
  const complete = true;
  const exportVersion = "1";

  const lines: GovernanceOperatorExportLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorExportDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorExportSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorExportReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorExportCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorExportVersion(exportVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorExportHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      export_version: exportVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
