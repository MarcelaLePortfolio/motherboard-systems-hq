import type {
  GovernanceOperatorHandoffLine,
  GovernanceOperatorHandoffRecord,
} from "./governance_operator_handoff_model";
import {
  formatGovernanceOperatorHandoffCompleteness,
  formatGovernanceOperatorHandoffDecision,
  formatGovernanceOperatorHandoffHeadline,
  formatGovernanceOperatorHandoffReadiness,
  formatGovernanceOperatorHandoffSections,
  formatGovernanceOperatorHandoffVersion,
} from "./governance_operator_handoff_formatter";

export interface GovernanceOperatorHandoffInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorHandoff(
  input: GovernanceOperatorHandoffInput,
): GovernanceOperatorHandoffRecord {
  const ready = true;
  const complete = true;
  const handoffVersion = "1";

  const lines: GovernanceOperatorHandoffLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorHandoffDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorHandoffSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorHandoffReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorHandoffCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorHandoffVersion(handoffVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorHandoffHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      handoff_version: handoffVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
