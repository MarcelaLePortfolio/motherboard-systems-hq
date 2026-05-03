import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorAtlasCompleteness,
  formatGovernanceOperatorAtlasDecision,
  formatGovernanceOperatorAtlasHeadline,
  formatGovernanceOperatorAtlasReadiness,
  formatGovernanceOperatorAtlasSections,
  formatGovernanceOperatorAtlasVersion,
} from "../../src/governance_operator_atlas/governance_operator_atlas_formatter";

describe("governance_operator_atlas_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorAtlasHeadline("dec-2100", "BLOCK")).toBe(
      "Governance operator atlas: dec-2100 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorAtlasDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorAtlasSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorAtlasSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorAtlasReadiness(true)).toBe("Atlas ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorAtlasCompleteness(true)).toBe(
      "Atlas complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorAtlasVersion("1")).toBe("Atlas version: 1");
  });
});
