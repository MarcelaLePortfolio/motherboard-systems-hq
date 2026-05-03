import type {
  GovernanceOperatorRecordLine,
  GovernanceOperatorRecordRecord,
} from "./governance_operator_record_model";
import {
  formatGovernanceOperatorRecordCompleteness,
  formatGovernanceOperatorRecordDecision,
  formatGovernanceOperatorRecordHeadline,
  formatGovernanceOperatorRecordReadiness,
  formatGovernanceOperatorRecordSections,
  formatGovernanceOperatorRecordVersion,
} from "./governance_operator_record_formatter";

export interface GovernanceOperatorRecordInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorRecord(
  input: GovernanceOperatorRecordInput,
): GovernanceOperatorRecordRecord {
  const ready = true;
  const complete = true;
  const recordVersion = "1";

  const lines: GovernanceOperatorRecordLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorRecordDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorRecordSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorRecordReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorRecordCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorRecordVersion(recordVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorRecordHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      record_version: recordVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
