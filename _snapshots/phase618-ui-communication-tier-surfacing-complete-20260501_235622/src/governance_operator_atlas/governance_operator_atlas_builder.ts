import type {
  GovernanceOperatorAtlasLine,
  GovernanceOperatorAtlasRecord,
} from "./governance_operator_atlas_model";
import {
  formatGovernanceOperatorAtlasCompleteness,
  formatGovernanceOperatorAtlasDecision,
  formatGovernanceOperatorAtlasHeadline,
  formatGovernanceOperatorAtlasReadiness,
  formatGovernanceOperatorAtlasSections,
  formatGovernanceOperatorAtlasVersion,
} from "./governance_operator_atlas_formatter";

export interface GovernanceOperatorAtlasInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorAtlas(
  input: GovernanceOperatorAtlasInput,
): GovernanceOperatorAtlasRecord {
  const ready = true;
  const complete = true;
  const atlasVersion = "1";

  const lines: GovernanceOperatorAtlasLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorAtlasDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorAtlasSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorAtlasReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorAtlasCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorAtlasVersion(atlasVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorAtlasHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      atlas_version: atlasVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
