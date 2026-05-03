import type {
  GovernanceOperatorReferenceLine,
  GovernanceOperatorReferenceRecord,
} from "./governance_operator_reference_model";
import {
  formatGovernanceOperatorReferenceCompleteness,
  formatGovernanceOperatorReferenceDecision,
  formatGovernanceOperatorReferenceHeadline,
  formatGovernanceOperatorReferenceReadiness,
  formatGovernanceOperatorReferenceSections,
  formatGovernanceOperatorReferenceVersion,
} from "./governance_operator_reference_formatter";

export interface GovernanceOperatorReferenceInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorReference(
  input: GovernanceOperatorReferenceInput,
): GovernanceOperatorReferenceRecord {
  const ready = true;
  const complete = true;
  const referenceVersion = "1";

  const lines: GovernanceOperatorReferenceLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorReferenceDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorReferenceSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorReferenceReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorReferenceCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorReferenceVersion(referenceVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorReferenceHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      reference_version: referenceVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
