import type {
  GovernanceOperatorGlossaryLine,
  GovernanceOperatorGlossaryRecord,
} from "./governance_operator_glossary_model";

import {
  formatGovernanceOperatorGlossaryCompleteness,
  formatGovernanceOperatorGlossaryHeadline,
  formatGovernanceOperatorGlossaryReadiness,
  formatGovernanceOperatorGlossaryTerms,
  formatGovernanceOperatorGlossaryVersion,
} from "./governance_operator_glossary_formatter";

export interface GovernanceOperatorGlossaryInput {
  terms?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorGlossary(
  input: GovernanceOperatorGlossaryInput,
): GovernanceOperatorGlossaryRecord {
  const ready = true;
  const complete = true;
  const version = "1";

  const lines: GovernanceOperatorGlossaryLine[] = [
    {
      key: "terms",
      text: formatGovernanceOperatorGlossaryTerms(input.terms ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorGlossaryReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorGlossaryCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorGlossaryVersion(version),
    },
  ];

  return {
    headline: formatGovernanceOperatorGlossaryHeadline(),
    metadata: {
      glossary_version: version,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
