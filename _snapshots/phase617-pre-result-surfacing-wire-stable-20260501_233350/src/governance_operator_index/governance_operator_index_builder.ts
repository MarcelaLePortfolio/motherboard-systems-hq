import type {
  GovernanceOperatorIndexLine,
  GovernanceOperatorIndexRecord,
} from "./governance_operator_index_model";
import {
  formatGovernanceOperatorIndexCompleteness,
  formatGovernanceOperatorIndexDecision,
  formatGovernanceOperatorIndexHeadline,
  formatGovernanceOperatorIndexReadiness,
  formatGovernanceOperatorIndexSections,
  formatGovernanceOperatorIndexVersion,
} from "./governance_operator_index_formatter";

export interface GovernanceOperatorIndexInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorIndex(
  input: GovernanceOperatorIndexInput,
): GovernanceOperatorIndexRecord {
  const ready = true;
  const complete = true;
  const indexVersion = "1";

  const lines: GovernanceOperatorIndexLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorIndexDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorIndexSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorIndexReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorIndexCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorIndexVersion(indexVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorIndexHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      index_version: indexVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
