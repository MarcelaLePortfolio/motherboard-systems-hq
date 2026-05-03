import type {
  GovernanceOperatorLexiconLine,
  GovernanceOperatorLexiconRecord,
} from "./governance_operator_lexicon_model";
import {
  formatGovernanceOperatorLexiconCompleteness,
  formatGovernanceOperatorLexiconHeadline,
  formatGovernanceOperatorLexiconReadiness,
  formatGovernanceOperatorLexiconTerms,
  formatGovernanceOperatorLexiconVersion,
} from "./governance_operator_lexicon_formatter";

export interface GovernanceOperatorLexiconInput {
  terms?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorLexicon(
  input: GovernanceOperatorLexiconInput,
): GovernanceOperatorLexiconRecord {
  const ready = true;
  const complete = true;
  const version = "1";

  const lines: GovernanceOperatorLexiconLine[] = [
    {
      key: "terms",
      text: formatGovernanceOperatorLexiconTerms(input.terms ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorLexiconReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorLexiconCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorLexiconVersion(version),
    },
  ];

  return {
    headline: formatGovernanceOperatorLexiconHeadline(),
    metadata: {
      lexicon_version: version,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
