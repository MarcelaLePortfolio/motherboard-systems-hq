import type {
  GovernanceOperatorManifestIndexLine,
  GovernanceOperatorManifestIndexRecord,
} from "./governance_operator_manifest_index_model";
import {
  formatGovernanceOperatorManifestIndexCompleteness,
  formatGovernanceOperatorManifestIndexDecision,
  formatGovernanceOperatorManifestIndexHeadline,
  formatGovernanceOperatorManifestIndexReadiness,
  formatGovernanceOperatorManifestIndexSections,
  formatGovernanceOperatorManifestIndexVersion,
} from "./governance_operator_manifest_index_formatter";

export interface GovernanceOperatorManifestIndexInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorManifestIndex(
  input: GovernanceOperatorManifestIndexInput,
): GovernanceOperatorManifestIndexRecord {
  const ready = true;
  const complete = true;
  const manifestIndexVersion = "1";

  const lines: GovernanceOperatorManifestIndexLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorManifestIndexDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorManifestIndexSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorManifestIndexReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorManifestIndexCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorManifestIndexVersion(manifestIndexVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorManifestIndexHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      manifest_index_version: manifestIndexVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
