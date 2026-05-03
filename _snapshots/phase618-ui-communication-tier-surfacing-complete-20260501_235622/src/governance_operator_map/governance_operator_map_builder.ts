import type {
  GovernanceOperatorMapLine,
  GovernanceOperatorMapRecord,
} from "./governance_operator_map_model";
import {
  formatGovernanceOperatorMapCompleteness,
  formatGovernanceOperatorMapDecision,
  formatGovernanceOperatorMapHeadline,
  formatGovernanceOperatorMapReadiness,
  formatGovernanceOperatorMapSections,
  formatGovernanceOperatorMapVersion,
} from "./governance_operator_map_formatter";

export interface GovernanceOperatorMapInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorMap(
  input: GovernanceOperatorMapInput,
): GovernanceOperatorMapRecord {
  const ready = true;
  const complete = true;
  const mapVersion = "1";

  const lines: GovernanceOperatorMapLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorMapDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorMapSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorMapReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorMapCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorMapVersion(mapVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorMapHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      map_version: mapVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
