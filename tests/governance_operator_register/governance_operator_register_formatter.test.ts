import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorRegisterCompleteness,
  formatGovernanceOperatorRegisterDecision,
  formatGovernanceOperatorRegisterHeadline,
  formatGovernanceOperatorRegisterReadiness,
  formatGovernanceOperatorRegisterSections,
  formatGovernanceOperatorRegisterVersion,
} from "../../src/governance_operator_register/governance_operator_register_formatter";

describe("governance_operator_register_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorRegisterHeadline("dec-1600", "BLOCK")).toBe(
      "Governance operator register: dec-1600 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorRegisterDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorRegisterSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorRegisterSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorRegisterReadiness(true)).toBe("Register ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorRegisterCompleteness(true)).toBe(
      "Register complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorRegisterVersion("1")).toBe("Register version: 1");
  });
});
