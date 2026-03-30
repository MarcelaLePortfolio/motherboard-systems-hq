import type {
  GovernanceOperatorGuideLine,
  GovernanceOperatorGuideRecord,
} from "./governance_operator_guide_model";
import {
  formatGovernanceOperatorGuideCompleteness,
  formatGovernanceOperatorGuideDecision,
  formatGovernanceOperatorGuideHeadline,
  formatGovernanceOperatorGuideReadiness,
  formatGovernanceOperatorGuideSections,
  formatGovernanceOperatorGuideVersion,
} from "./governance_operator_guide_formatter";

export interface GovernanceOperatorGuideInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorGuide(
  input: GovernanceOperatorGuideInput,
): GovernanceOperatorGuideRecord {
  const ready = true;
  const complete = true;
  const guideVersion = "1";

  const lines: GovernanceOperatorGuideLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorGuideDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorGuideSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorGuideReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorGuideCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorGuideVersion(guideVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorGuideHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      guide_version: guideVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
