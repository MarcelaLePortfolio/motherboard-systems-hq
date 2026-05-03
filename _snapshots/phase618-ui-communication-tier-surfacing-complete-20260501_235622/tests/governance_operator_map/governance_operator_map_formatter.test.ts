import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorMapCompleteness,
  formatGovernanceOperatorMapDecision,
  formatGovernanceOperatorMapHeadline,
  formatGovernanceOperatorMapReadiness,
  formatGovernanceOperatorMapSections,
  formatGovernanceOperatorMapVersion,
} from "../../src/governance_operator_map/governance_operator_map_formatter";

describe("governance_operator_map_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorMapHeadline("dec-2000", "BLOCK")).toBe(
      "Governance operator map: dec-2000 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorMapDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorMapSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorMapSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorMapReadiness(true)).toBe("Map ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorMapCompleteness(true)).toBe(
      "Map complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorMapVersion("1")).toBe("Map version: 1");
  });
});
