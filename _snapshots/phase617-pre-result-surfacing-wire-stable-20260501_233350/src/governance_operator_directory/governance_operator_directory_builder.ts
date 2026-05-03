import type {
  GovernanceOperatorDirectoryLine,
  GovernanceOperatorDirectoryRecord,
} from "./governance_operator_directory_model";
import {
  formatGovernanceOperatorDirectoryCompleteness,
  formatGovernanceOperatorDirectoryDecision,
  formatGovernanceOperatorDirectoryHeadline,
  formatGovernanceOperatorDirectoryReadiness,
  formatGovernanceOperatorDirectorySections,
  formatGovernanceOperatorDirectoryVersion,
} from "./governance_operator_directory_formatter";

export interface GovernanceOperatorDirectoryInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorDirectory(
  input: GovernanceOperatorDirectoryInput,
): GovernanceOperatorDirectoryRecord {
  const ready = true;
  const complete = true;
  const directoryVersion = "1";

  const lines: GovernanceOperatorDirectoryLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorDirectoryDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorDirectorySections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorDirectoryReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorDirectoryCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorDirectoryVersion(directoryVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorDirectoryHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      directory_version: directoryVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
