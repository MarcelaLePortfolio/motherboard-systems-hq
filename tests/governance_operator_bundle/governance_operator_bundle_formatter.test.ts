import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorBundleCompleteness,
  formatGovernanceOperatorBundleDecision,
  formatGovernanceOperatorBundleHeadline,
  formatGovernanceOperatorBundleReadiness,
  formatGovernanceOperatorBundleSections,
  formatGovernanceOperatorBundleVersion,
} from "../../src/governance_operator_bundle/governance_operator_bundle_formatter";

describe("governance_operator_bundle_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorBundleHeadline("dec-1100", "BLOCK")).toBe(
      "Governance operator bundle: dec-1100 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorBundleDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorBundleSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorBundleSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorBundleReadiness(true)).toBe("Bundle ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorBundleCompleteness(true)).toBe(
      "Bundle complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorBundleVersion("1")).toBe("Bundle version: 1");
  });
});
