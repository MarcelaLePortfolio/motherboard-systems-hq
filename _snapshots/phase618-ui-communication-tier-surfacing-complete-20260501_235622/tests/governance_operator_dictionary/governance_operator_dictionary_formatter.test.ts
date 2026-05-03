import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorDictionaryCompleteness,
  formatGovernanceOperatorDictionaryHeadline,
  formatGovernanceOperatorDictionaryReadiness,
  formatGovernanceOperatorDictionaryTerms,
  formatGovernanceOperatorDictionaryVersion,
} from "../../src/governance_operator_dictionary/governance_operator_dictionary_formatter";

describe("governance_operator_dictionary_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorDictionaryHeadline())
      .toBe("Governance operator dictionary");
  });

  it("formats terms", () => {
    expect(formatGovernanceOperatorDictionaryTerms(["governance", "operator"]))
      .toBe("Terms: governance, operator");
  });

  it("formats empty terms", () => {
    expect(formatGovernanceOperatorDictionaryTerms([]))
      .toBe("Terms: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorDictionaryReadiness(true))
      .toBe("Dictionary ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorDictionaryCompleteness(true))
      .toBe("Dictionary complete: yes");
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorDictionaryVersion("1"))
      .toBe("Dictionary version: 1");
  });
});
