import type {
  GovernanceOperatorConsoleLine,
  GovernanceOperatorConsoleRecord,
} from "./governance_operator_console_model";
import {
  formatGovernanceOperatorConsoleCompleteness,
  formatGovernanceOperatorConsoleDecision,
  formatGovernanceOperatorConsoleHeadline,
  formatGovernanceOperatorConsoleReadiness,
  formatGovernanceOperatorConsoleSections,
  formatGovernanceOperatorConsoleVersion,
} from "./governance_operator_console_formatter";

export interface GovernanceOperatorConsoleInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorConsole(
  input: GovernanceOperatorConsoleInput,
): GovernanceOperatorConsoleRecord {
  const ready = true;
  const complete = true;
  const consoleVersion = "1";

  const lines: GovernanceOperatorConsoleLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorConsoleDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorConsoleSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorConsoleReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorConsoleCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorConsoleVersion(consoleVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorConsoleHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      console_version: consoleVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
