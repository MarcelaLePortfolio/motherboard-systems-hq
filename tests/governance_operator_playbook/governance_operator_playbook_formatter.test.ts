import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorPlaybookCompleteness,
  formatGovernanceOperatorPlaybookDecision,
  formatGovernanceOperatorPlaybookHeadline,
  formatGovernanceOperatorPlaybookReadiness,
  formatGovernanceOperatorPlaybookSections,
  formatGovernanceOperatorPlaybookVersion,
} from "../../src/governance_operator_playbook/governance_operator_playbook_formatter";

describe("governance_operator_playbook_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorPlaybookHeadline("dec-2700", "BLOCK")).toBe(
      "Governance operator playbook: dec-2700 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorPlaybookDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorPlaybookSections(["Overview", "Manual", "Playbook"]),
    ).toBe("Sections: Overview, Manual, Playbook");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorPlaybookSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorPlaybookReadiness(true)).toBe("Playbook ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorPlaybookCompleteness(true)).toBe(
      "Playbook complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorPlaybookVersion("1")).toBe("Playbook version: 1");
  });
});
