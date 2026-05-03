import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorHandoffCompleteness,
  formatGovernanceOperatorHandoffDecision,
  formatGovernanceOperatorHandoffHeadline,
  formatGovernanceOperatorHandoffReadiness,
  formatGovernanceOperatorHandoffSections,
  formatGovernanceOperatorHandoffVersion,
} from "../../src/governance_operator_handoff/governance_operator_handoff_formatter";

describe("governance_operator_handoff_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorHandoffHeadline("dec-800", "BLOCK")).toBe(
      "Governance operator handoff: dec-800 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorHandoffDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorHandoffSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorHandoffSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorHandoffReadiness(true)).toBe("Handoff ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorHandoffCompleteness(true)).toBe(
      "Handoff complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorHandoffVersion("1")).toBe("Handoff version: 1");
  });
});
