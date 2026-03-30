import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorGlossaryCompleteness,
  formatGovernanceOperatorGlossaryHeadline,
  formatGovernanceOperatorGlossaryReadiness,
  formatGovernanceOperatorGlossaryTerms,
  formatGovernanceOperatorGlossaryVersion,
} from "../../src/governance_operator_glossary/governance_operator_glossary_formatter";

describe("governance_operator_glossary_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorGlossaryHeadline())
      .toBe("Governance operator glossary");
  });

  it("formats terms", () => {
    expect(formatGovernanceOperatorGlossaryTerms(["governance","operator"]))
      .toBe("Terms: governance, operator");
  });

  it("formats empty terms", () => {
    expect(formatGovernanceOperatorGlossaryTerms([]))
      .toBe("Terms: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorGlossaryReadiness(true))
      .toBe("Glossary ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorGlossaryCompleteness(true))
      .toBe("Glossary complete: yes");
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorGlossaryVersion("1"))
      .toBe("Glossary version: 1");
  });
});
