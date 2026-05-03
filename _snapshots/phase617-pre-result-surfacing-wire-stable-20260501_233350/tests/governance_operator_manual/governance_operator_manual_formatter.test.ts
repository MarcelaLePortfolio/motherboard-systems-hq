import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorManualCompleteness,
  formatGovernanceOperatorManualDecision,
  formatGovernanceOperatorManualHeadline,
  formatGovernanceOperatorManualReadiness,
  formatGovernanceOperatorManualSections,
  formatGovernanceOperatorManualVersion,
} from "../../src/governance_operator_manual/governance_operator_manual_formatter";

describe("governance_operator_manual_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorManualHeadline("dec-2600", "BLOCK")).toBe(
      "Governance operator manual: dec-2600 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorManualDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorManualSections(["Overview", "Guide", "Manual"]),
    ).toBe("Sections: Overview, Guide, Manual");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorManualSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorManualReadiness(true)).toBe("Manual ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorManualCompleteness(true)).toBe(
      "Manual complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorManualVersion("1")).toBe("Manual version: 1");
  });
});
