import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorBriefingCompleteness,
  formatGovernanceOperatorBriefingDecision,
  formatGovernanceOperatorBriefingHeadline,
  formatGovernanceOperatorBriefingReadiness,
  formatGovernanceOperatorBriefingSections,
  formatGovernanceOperatorBriefingVersion,
} from "../../src/governance_operator_briefing/governance_operator_briefing_formatter";

describe("governance_operator_briefing_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorBriefingHeadline("dec-600", "BLOCK")).toBe(
      "Governance operator briefing: dec-600 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorBriefingDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorBriefingSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorBriefingSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorBriefingReadiness(true)).toBe("Briefing ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorBriefingCompleteness(true)).toBe(
      "Briefing complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorBriefingVersion("1")).toBe("Briefing version: 1");
  });
});
