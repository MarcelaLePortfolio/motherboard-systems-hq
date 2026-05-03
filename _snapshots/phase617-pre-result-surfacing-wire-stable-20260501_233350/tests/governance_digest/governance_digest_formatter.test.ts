import { describe, expect, it } from "vitest";
import {
  formatGovernanceDigestArtifacts,
  formatGovernanceDigestDecision,
  formatGovernanceDigestHeadline,
  formatGovernanceDigestInvariants,
  formatGovernanceDigestPolicy,
  formatGovernanceDigestProvenance,
  formatGovernanceDigestStages,
} from "../../src/governance_digest/governance_digest_formatter";

describe("governance_digest_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceDigestHeadline("dec-300", "BLOCK")).toBe(
      "Governance digest: dec-300 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceDigestDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats policy", () => {
    expect(formatGovernanceDigestPolicy("policy.alpha")).toBe(
      "Policy route: policy.alpha",
    );
  });

  it("formats missing policy", () => {
    expect(formatGovernanceDigestPolicy(null)).toBe("Policy route: none");
  });

  it("formats invariants", () => {
    expect(
      formatGovernanceDigestInvariants(["authority-boundary", "registry-safety"]),
    ).toBe("Invariants: authority-boundary, registry-safety");
  });

  it("formats stages", () => {
    expect(
      formatGovernanceDigestStages(["signal_classification", "policy_routing"]),
    ).toBe("Stages: signal_classification, policy_routing");
  });

  it("formats artifacts", () => {
    expect(formatGovernanceDigestArtifacts(true, false)).toBe(
      "Artifacts: explanation=yes, audit=no",
    );
  });

  it("formats provenance", () => {
    expect(formatGovernanceDigestProvenance("deterministic governance path")).toBe(
      "Provenance: deterministic governance path",
    );
  });
});
