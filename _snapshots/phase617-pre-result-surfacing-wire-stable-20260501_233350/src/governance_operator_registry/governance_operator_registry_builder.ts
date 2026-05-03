import type {
  GovernanceOperatorRegistryLine,
  GovernanceOperatorRegistryRecord,
} from "./governance_operator_registry_model";
import {
  formatGovernanceOperatorRegistryCompleteness,
  formatGovernanceOperatorRegistryDecision,
  formatGovernanceOperatorRegistryHeadline,
  formatGovernanceOperatorRegistryReadiness,
  formatGovernanceOperatorRegistrySections,
  formatGovernanceOperatorRegistryVersion,
} from "./governance_operator_registry_formatter";

export interface GovernanceOperatorRegistryInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorRegistry(
  input: GovernanceOperatorRegistryInput,
): GovernanceOperatorRegistryRecord {
  const ready = true;
  const complete = true;
  const registryVersion = "1";

  const lines: GovernanceOperatorRegistryLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorRegistryDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorRegistrySections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorRegistryReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorRegistryCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorRegistryVersion(registryVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorRegistryHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      registry_version: registryVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
