import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorManifestIndexCompleteness,
  formatGovernanceOperatorManifestIndexDecision,
  formatGovernanceOperatorManifestIndexHeadline,
  formatGovernanceOperatorManifestIndexReadiness,
  formatGovernanceOperatorManifestIndexSections,
  formatGovernanceOperatorManifestIndexVersion,
} from "../../src/governance_operator_manifest_index/governance_operator_manifest_index_formatter";

describe("governance_operator_manifest_index_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorManifestIndexHeadline("dec-1900", "BLOCK")).toBe(
      "Governance operator manifest index: dec-1900 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorManifestIndexDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorManifestIndexSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorManifestIndexSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorManifestIndexReadiness(true)).toBe("Manifest index ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorManifestIndexCompleteness(true)).toBe(
      "Manifest index complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorManifestIndexVersion("1")).toBe("Manifest index version: 1");
  });
});
