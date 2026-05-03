import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorExportCompleteness,
  formatGovernanceOperatorExportDecision,
  formatGovernanceOperatorExportHeadline,
  formatGovernanceOperatorExportReadiness,
  formatGovernanceOperatorExportSections,
  formatGovernanceOperatorExportVersion,
} from "../../src/governance_operator_export/governance_operator_export_formatter";

describe("governance_operator_export_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorExportHeadline("dec-1200", "BLOCK")).toBe(
      "Governance operator export: dec-1200 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorExportDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorExportSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorExportSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorExportReadiness(true)).toBe("Export ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorExportCompleteness(true)).toBe(
      "Export complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorExportVersion("1")).toBe("Export version: 1");
  });
});
