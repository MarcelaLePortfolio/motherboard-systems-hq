import type {
  GovernanceOperatorCompendiumLine,
  GovernanceOperatorCompendiumRecord,
} from "./governance_operator_compendium_model";
import {
  formatGovernanceOperatorCompendiumCompleteness,
  formatGovernanceOperatorCompendiumDecision,
  formatGovernanceOperatorCompendiumHeadline,
  formatGovernanceOperatorCompendiumReadiness,
  formatGovernanceOperatorCompendiumSections,
  formatGovernanceOperatorCompendiumVersion,
} from "./governance_operator_compendium_formatter";

export interface GovernanceOperatorCompendiumInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorCompendium(
  input: GovernanceOperatorCompendiumInput,
): GovernanceOperatorCompendiumRecord {
  const ready = true;
  const complete = true;
  const compendiumVersion = "1";

  const lines: GovernanceOperatorCompendiumLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorCompendiumDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorCompendiumSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorCompendiumReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorCompendiumCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorCompendiumVersion(compendiumVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorCompendiumHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      compendium_version: compendiumVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
