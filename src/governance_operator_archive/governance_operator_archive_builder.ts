import type {
  GovernanceOperatorArchiveLine,
  GovernanceOperatorArchiveRecord,
} from "./governance_operator_archive_model";
import {
  formatGovernanceOperatorArchiveCompleteness,
  formatGovernanceOperatorArchiveDecision,
  formatGovernanceOperatorArchiveHeadline,
  formatGovernanceOperatorArchiveReadiness,
  formatGovernanceOperatorArchiveSections,
  formatGovernanceOperatorArchiveVersion,
} from "./governance_operator_archive_formatter";

export interface GovernanceOperatorArchiveInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorArchive(
  input: GovernanceOperatorArchiveInput,
): GovernanceOperatorArchiveRecord {
  const ready = true;
  const complete = true;
  const archiveVersion = "1";

  const lines: GovernanceOperatorArchiveLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorArchiveDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorArchiveSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorArchiveReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorArchiveCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorArchiveVersion(archiveVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorArchiveHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      archive_version: archiveVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
