import type {
  GovernanceOperatorRegisterLine,
  GovernanceOperatorRegisterRecord,
} from "./governance_operator_register_model";
import {
  formatGovernanceOperatorRegisterCompleteness,
  formatGovernanceOperatorRegisterDecision,
  formatGovernanceOperatorRegisterHeadline,
  formatGovernanceOperatorRegisterReadiness,
  formatGovernanceOperatorRegisterSections,
  formatGovernanceOperatorRegisterVersion,
} from "./governance_operator_register_formatter";

export interface GovernanceOperatorRegisterInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorRegister(
  input: GovernanceOperatorRegisterInput,
): GovernanceOperatorRegisterRecord {
  const ready = true;
  const complete = true;
  const registerVersion = "1";

  const lines: GovernanceOperatorRegisterLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorRegisterDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorRegisterSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorRegisterReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorRegisterCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorRegisterVersion(registerVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorRegisterHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      register_version: registerVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
