import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorManifestCompleteness,
  formatGovernanceOperatorManifestDecision,
  formatGovernanceOperatorManifestHeadline,
  formatGovernanceOperatorManifestReadiness,
  formatGovernanceOperatorManifestSections,
  formatGovernanceOperatorManifestVersion,
} from "../../src/governance_operator_manifest/governance_operator_manifest_formatter";

describe("governance_operator_manifest_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorManifestHeadline("dec-500", "BLOCK")).toBe(
      "Governance operator manifest: dec-500 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorManifestDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorManifestSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorManifestSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorManifestReadiness(true)).toBe("Manifest ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorManifestCompleteness(true)).toBe(
      "Manifest complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorManifestVersion("1")).toBe("Manifest version: 1");
  });
});
