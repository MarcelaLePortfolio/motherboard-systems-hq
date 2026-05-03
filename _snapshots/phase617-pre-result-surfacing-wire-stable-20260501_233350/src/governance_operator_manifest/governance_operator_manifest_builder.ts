import type {
  GovernanceOperatorManifestEntry,
  GovernanceOperatorManifestRecord,
} from "./governance_operator_manifest_model";
import {
  formatGovernanceOperatorManifestCompleteness,
  formatGovernanceOperatorManifestDecision,
  formatGovernanceOperatorManifestHeadline,
  formatGovernanceOperatorManifestReadiness,
  formatGovernanceOperatorManifestSections,
  formatGovernanceOperatorManifestVersion,
} from "./governance_operator_manifest_formatter";

export interface GovernanceOperatorManifestInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorManifest(
  input: GovernanceOperatorManifestInput,
): GovernanceOperatorManifestRecord {
  const ready = true;
  const complete = true;
  const manifestVersion = "1";

  const entries: GovernanceOperatorManifestEntry[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorManifestDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorManifestSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorManifestReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorManifestCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorManifestVersion(manifestVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorManifestHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      manifest_version: manifestVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    entries,
  };
}
