import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorReferenceCompleteness,
  formatGovernanceOperatorReferenceDecision,
  formatGovernanceOperatorReferenceHeadline,
  formatGovernanceOperatorReferenceReadiness,
  formatGovernanceOperatorReferenceSections,
  formatGovernanceOperatorReferenceVersion,
} from "../../src/governance_operator_reference/governance_operator_reference_formatter";

describe("governance_operator_reference_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorReferenceHeadline("dec-3000", "BLOCK")).toBe(
      "Governance operator reference: dec-3000 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorReferenceDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorReferenceSections(["Overview", "Compendium", "Reference"]),
    ).toBe("Sections: Overview, Compendium, Reference");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorReferenceSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorReferenceReadiness(true)).toBe("Reference ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorReferenceCompleteness(true)).toBe(
      "Reference complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorReferenceVersion("1")).toBe("Reference version: 1");
  });
});
