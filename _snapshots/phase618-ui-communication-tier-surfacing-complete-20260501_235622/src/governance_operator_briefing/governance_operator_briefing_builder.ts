import type {
  GovernanceOperatorBriefingLine,
  GovernanceOperatorBriefingRecord,
} from "./governance_operator_briefing_model";
import {
  formatGovernanceOperatorBriefingCompleteness,
  formatGovernanceOperatorBriefingDecision,
  formatGovernanceOperatorBriefingHeadline,
  formatGovernanceOperatorBriefingReadiness,
  formatGovernanceOperatorBriefingSections,
  formatGovernanceOperatorBriefingVersion,
} from "./governance_operator_briefing_formatter";

export interface GovernanceOperatorBriefingInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorBriefing(
  input: GovernanceOperatorBriefingInput,
): GovernanceOperatorBriefingRecord {
  const ready = true;
  const complete = true;
  const briefingVersion = "1";

  const lines: GovernanceOperatorBriefingLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorBriefingDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorBriefingSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorBriefingReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorBriefingCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorBriefingVersion(briefingVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorBriefingHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      briefing_version: briefingVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
