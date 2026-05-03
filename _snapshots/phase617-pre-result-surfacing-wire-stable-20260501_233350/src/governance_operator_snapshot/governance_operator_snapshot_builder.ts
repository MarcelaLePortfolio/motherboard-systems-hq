import type {
  GovernanceOperatorSnapshotLine,
  GovernanceOperatorSnapshotRecord,
} from "./governance_operator_snapshot_model";
import {
  formatGovernanceOperatorSnapshotCompleteness,
  formatGovernanceOperatorSnapshotDecision,
  formatGovernanceOperatorSnapshotHeadline,
  formatGovernanceOperatorSnapshotReadiness,
  formatGovernanceOperatorSnapshotSections,
  formatGovernanceOperatorSnapshotVersion,
} from "./governance_operator_snapshot_formatter";

export interface GovernanceOperatorSnapshotInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorSnapshot(
  input: GovernanceOperatorSnapshotInput,
): GovernanceOperatorSnapshotRecord {
  const ready = true;
  const complete = true;
  const snapshotVersion = "1";

  const lines: GovernanceOperatorSnapshotLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorSnapshotDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorSnapshotSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorSnapshotReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorSnapshotCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorSnapshotVersion(snapshotVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorSnapshotHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      snapshot_version: snapshotVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
