import type {
  GovernanceOperatorManualLine,
  GovernanceOperatorManualRecord,
} from "./governance_operator_manual_model";
import {
  formatGovernanceOperatorManualCompleteness,
  formatGovernanceOperatorManualDecision,
  formatGovernanceOperatorManualHeadline,
  formatGovernanceOperatorManualReadiness,
  formatGovernanceOperatorManualSections,
  formatGovernanceOperatorManualVersion,
} from "./governance_operator_manual_formatter";

export interface GovernanceOperatorManualInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorManual(
  input: GovernanceOperatorManualInput,
): GovernanceOperatorManualRecord {
  const ready = true;
  const complete = true;
  const manualVersion = "1";

  const lines: GovernanceOperatorManualLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorManualDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorManualSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorManualReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorManualCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorManualVersion(manualVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorManualHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      manual_version: manualVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
