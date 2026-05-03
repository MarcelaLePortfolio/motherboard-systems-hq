import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorHandbookCompleteness,
  formatGovernanceOperatorHandbookDecision,
  formatGovernanceOperatorHandbookHeadline,
  formatGovernanceOperatorHandbookReadiness,
  formatGovernanceOperatorHandbookSections,
  formatGovernanceOperatorHandbookVersion,
} from "../../src/governance_operator_handbook/governance_operator_handbook_formatter";

describe("governance_operator_handbook_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorHandbookHeadline("dec-2800", "BLOCK")).toBe(
      "Governance operator handbook: dec-2800 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorHandbookDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorHandbookSections(["Overview", "Playbook", "Handbook"]),
    ).toBe("Sections: Overview, Playbook, Handbook");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorHandbookSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorHandbookReadiness(true)).toBe("Handbook ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorHandbookCompleteness(true)).toBe(
      "Handbook complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorHandbookVersion("1")).toBe("Handbook version: 1");
  });
});
