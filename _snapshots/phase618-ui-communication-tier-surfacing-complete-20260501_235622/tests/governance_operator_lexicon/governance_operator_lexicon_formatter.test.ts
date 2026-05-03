import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorLexiconCompleteness,
  formatGovernanceOperatorLexiconHeadline,
  formatGovernanceOperatorLexiconReadiness,
  formatGovernanceOperatorLexiconTerms,
  formatGovernanceOperatorLexiconVersion,
} from "../../src/governance_operator_lexicon/governance_operator_lexicon_formatter";

describe("governance_operator_lexicon_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorLexiconHeadline())
      .toBe("Governance operator lexicon");
  });

  it("formats terms", () => {
    expect(formatGovernanceOperatorLexiconTerms(["governance", "operator"]))
      .toBe("Terms: governance, operator");
  });

  it("formats empty terms", () => {
    expect(formatGovernanceOperatorLexiconTerms([]))
      .toBe("Terms: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorLexiconReadiness(true))
      .toBe("Lexicon ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorLexiconCompleteness(true))
      .toBe("Lexicon complete: yes");
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorLexiconVersion("1"))
      .toBe("Lexicon version: 1");
  });
});
