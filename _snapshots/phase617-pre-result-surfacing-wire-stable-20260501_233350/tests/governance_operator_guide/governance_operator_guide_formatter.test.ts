import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorGuideCompleteness,
  formatGovernanceOperatorGuideDecision,
  formatGovernanceOperatorGuideHeadline,
  formatGovernanceOperatorGuideReadiness,
  formatGovernanceOperatorGuideSections,
  formatGovernanceOperatorGuideVersion,
} from "../../src/governance_operator_guide/governance_operator_guide_formatter";

describe("governance_operator_guide_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorGuideHeadline("dec-2500", "BLOCK")).toBe(
      "Governance operator guide: dec-2500 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorGuideDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorGuideSections(["Overview", "Directory", "Guide"]),
    ).toBe("Sections: Overview, Directory, Guide");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorGuideSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorGuideReadiness(true)).toBe("Guide ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorGuideCompleteness(true)).toBe(
      "Guide complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorGuideVersion("1")).toBe("Guide version: 1");
  });
});
