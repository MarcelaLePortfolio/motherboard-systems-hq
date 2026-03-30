import type {
  GovernanceOperatorHandbookLine,
  GovernanceOperatorHandbookRecord,
} from "./governance_operator_handbook_model";
import {
  formatGovernanceOperatorHandbookCompleteness,
  formatGovernanceOperatorHandbookDecision,
  formatGovernanceOperatorHandbookHeadline,
  formatGovernanceOperatorHandbookReadiness,
  formatGovernanceOperatorHandbookSections,
  formatGovernanceOperatorHandbookVersion,
} from "./governance_operator_handbook_formatter";

export interface GovernanceOperatorHandbookInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorHandbook(
  input: GovernanceOperatorHandbookInput,
): GovernanceOperatorHandbookRecord {
  const ready = true;
  const complete = true;
  const handbookVersion = "1";

  const lines: GovernanceOperatorHandbookLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorHandbookDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorHandbookSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorHandbookReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorHandbookCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorHandbookVersion(handbookVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorHandbookHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      handbook_version: handbookVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
