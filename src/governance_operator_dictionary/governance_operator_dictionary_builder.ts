import type {
  GovernanceOperatorDictionaryLine,
  GovernanceOperatorDictionaryRecord,
} from "./governance_operator_dictionary_model";
import {
  formatGovernanceOperatorDictionaryCompleteness,
  formatGovernanceOperatorDictionaryHeadline,
  formatGovernanceOperatorDictionaryReadiness,
  formatGovernanceOperatorDictionaryTerms,
  formatGovernanceOperatorDictionaryVersion,
} from "./governance_operator_dictionary_formatter";

export interface GovernanceOperatorDictionaryInput {
  terms?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorDictionary(
  input: GovernanceOperatorDictionaryInput,
): GovernanceOperatorDictionaryRecord {
  const ready = true;
  const complete = true;
  const version = "1";

  const lines: GovernanceOperatorDictionaryLine[] = [
    {
      key: "terms",
      text: formatGovernanceOperatorDictionaryTerms(input.terms ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorDictionaryReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorDictionaryCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorDictionaryVersion(version),
    },
  ];

  return {
    headline: formatGovernanceOperatorDictionaryHeadline(),
    metadata: {
      dictionary_version: version,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
