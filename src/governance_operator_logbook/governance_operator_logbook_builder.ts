import type {
  GovernanceOperatorLogbookLine,
  GovernanceOperatorLogbookRecord,
} from "./governance_operator_logbook_model";
import {
  formatGovernanceOperatorLogbookCompleteness,
  formatGovernanceOperatorLogbookDecision,
  formatGovernanceOperatorLogbookHeadline,
  formatGovernanceOperatorLogbookReadiness,
  formatGovernanceOperatorLogbookSections,
  formatGovernanceOperatorLogbookVersion,
} from "./governance_operator_logbook_formatter";

export interface GovernanceOperatorLogbookInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorLogbook(
  input: GovernanceOperatorLogbookInput,
): GovernanceOperatorLogbookRecord {
  const ready = true;
  const complete = true;
  const logbookVersion = "1";

  const lines: GovernanceOperatorLogbookLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorLogbookDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorLogbookSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorLogbookReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorLogbookCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorLogbookVersion(logbookVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorLogbookHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      logbook_version: logbookVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
