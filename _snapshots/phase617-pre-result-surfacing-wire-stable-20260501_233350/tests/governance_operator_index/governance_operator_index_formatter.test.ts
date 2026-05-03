import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorIndexCompleteness,
  formatGovernanceOperatorIndexDecision,
  formatGovernanceOperatorIndexHeadline,
  formatGovernanceOperatorIndexReadiness,
  formatGovernanceOperatorIndexSections,
  formatGovernanceOperatorIndexVersion,
} from "../../src/governance_operator_index/governance_operator_index_formatter";

describe("governance_operator_index_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorIndexHeadline("dec-1800", "BLOCK")).toBe(
      "Governance operator index: dec-1800 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorIndexDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorIndexSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorIndexSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorIndexReadiness(true)).toBe("Index ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorIndexCompleteness(true)).toBe(
      "Index complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorIndexVersion("1")).toBe("Index version: 1");
  });
});
