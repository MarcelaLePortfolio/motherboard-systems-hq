import type {
  GovernanceOperatorBundleLine,
  GovernanceOperatorBundleRecord,
} from "./governance_operator_bundle_model";
import {
  formatGovernanceOperatorBundleCompleteness,
  formatGovernanceOperatorBundleDecision,
  formatGovernanceOperatorBundleHeadline,
  formatGovernanceOperatorBundleReadiness,
  formatGovernanceOperatorBundleSections,
  formatGovernanceOperatorBundleVersion,
} from "./governance_operator_bundle_formatter";

export interface GovernanceOperatorBundleInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorBundle(
  input: GovernanceOperatorBundleInput,
): GovernanceOperatorBundleRecord {
  const ready = true;
  const complete = true;
  const bundleVersion = "1";

  const lines: GovernanceOperatorBundleLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorBundleDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorBundleSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorBundleReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorBundleCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorBundleVersion(bundleVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorBundleHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      bundle_version: bundleVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
