import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorRecordCompleteness,
  formatGovernanceOperatorRecordDecision,
  formatGovernanceOperatorRecordHeadline,
  formatGovernanceOperatorRecordReadiness,
  formatGovernanceOperatorRecordSections,
  formatGovernanceOperatorRecordVersion,
} from "../../src/governance_operator_record/governance_operator_record_formatter";

describe("governance_operator_record_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorRecordHeadline("dec-1400", "BLOCK")).toBe(
      "Governance operator record: dec-1400 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorRecordDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorRecordSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorRecordSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorRecordReadiness(true)).toBe("Record ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorRecordCompleteness(true)).toBe(
      "Record complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorRecordVersion("1")).toBe("Record version: 1");
  });
});
