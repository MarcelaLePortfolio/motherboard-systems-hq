import type {
  GovernanceOperatorSessionLine,
  GovernanceOperatorSessionRecord,
} from "./governance_operator_session_model";
import {
  formatGovernanceOperatorSessionCompleteness,
  formatGovernanceOperatorSessionDecision,
  formatGovernanceOperatorSessionHeadline,
  formatGovernanceOperatorSessionReadiness,
  formatGovernanceOperatorSessionSections,
  formatGovernanceOperatorSessionVersion,
} from "./governance_operator_session_formatter";

export interface GovernanceOperatorSessionInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorSession(
  input: GovernanceOperatorSessionInput,
): GovernanceOperatorSessionRecord {
  const ready = true;
  const complete = true;
  const sessionVersion = "1";

  const lines: GovernanceOperatorSessionLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorSessionDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorSessionSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorSessionReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorSessionCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorSessionVersion(sessionVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorSessionHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      session_version: sessionVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
