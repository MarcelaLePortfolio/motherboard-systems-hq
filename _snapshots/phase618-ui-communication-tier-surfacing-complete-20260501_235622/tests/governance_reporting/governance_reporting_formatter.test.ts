import { describe, expect, it } from "vitest";
import {
  formatGovernanceReportDecision,
  formatGovernanceReportHeadline,
  formatGovernanceReportInvariants,
  formatGovernanceReportPolicy,
  formatGovernanceReportProvenance,
  formatGovernanceReportStages,
} from "../../src/governance_reporting/governance_reporting_formatter";

describe("governance_reporting_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceReportHeadline("dec-200", "BLOCK")).toBe(
      "Governance report: dec-200 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceReportDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats policy", () => {
    expect(formatGovernanceReportPolicy("policy.alpha")).toBe(
      "Policy route: policy.alpha",
    );
  });

  it("formats missing policy", () => {
    expect(formatGovernanceReportPolicy(null)).toBe("Policy route: none");
  });

  it("formats invariants", () => {
    expect(
      formatGovernanceReportInvariants(["authority-boundary", "registry-safety"]),
    ).toBe("Invariants triggered: authority-boundary, registry-safety");
  });

  it("formats stages", () => {
    expect(
      formatGovernanceReportStages(["signal_classification", "policy_routing"]),
    ).toBe("Completed stages: signal_classification, policy_routing");
  });

  it("formats provenance", () => {
    expect(formatGovernanceReportProvenance("deterministic governance path")).toBe(
      "Provenance: deterministic governance path",
    );
  });
});
