import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorLogbookCompleteness,
  formatGovernanceOperatorLogbookDecision,
  formatGovernanceOperatorLogbookHeadline,
  formatGovernanceOperatorLogbookReadiness,
  formatGovernanceOperatorLogbookSections,
  formatGovernanceOperatorLogbookVersion,
} from "../../src/governance_operator_logbook/governance_operator_logbook_formatter";

describe("governance_operator_logbook_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorLogbookHeadline("dec-1500", "BLOCK")).toBe(
      "Governance operator logbook: dec-1500 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorLogbookDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorLogbookSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorLogbookSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorLogbookReadiness(true)).toBe("Logbook ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorLogbookCompleteness(true)).toBe(
      "Logbook complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorLogbookVersion("1")).toBe("Logbook version: 1");
  });
});
