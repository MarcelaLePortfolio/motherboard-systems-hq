import type {
  GovernanceOperatorPlaybookLine,
  GovernanceOperatorPlaybookRecord,
} from "./governance_operator_playbook_model";
import {
  formatGovernanceOperatorPlaybookCompleteness,
  formatGovernanceOperatorPlaybookDecision,
  formatGovernanceOperatorPlaybookHeadline,
  formatGovernanceOperatorPlaybookReadiness,
  formatGovernanceOperatorPlaybookSections,
  formatGovernanceOperatorPlaybookVersion,
} from "./governance_operator_playbook_formatter";

export interface GovernanceOperatorPlaybookInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorPlaybook(
  input: GovernanceOperatorPlaybookInput,
): GovernanceOperatorPlaybookRecord {
  const ready = true;
  const complete = true;
  const playbookVersion = "1";

  const lines: GovernanceOperatorPlaybookLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorPlaybookDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorPlaybookSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorPlaybookReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorPlaybookCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorPlaybookVersion(playbookVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorPlaybookHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      playbook_version: playbookVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
