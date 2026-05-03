import { describe, expect, it } from "vitest";
import { buildGovernanceDigest } from "../../src/governance_digest/governance_digest_builder";

describe("governance_digest_builder", () => {
  it("builds a deterministic governance digest", () => {
    const result = buildGovernanceDigest({
      decision_id: "dec-301",
      decision: "WARN",
      policy_route: "policy.alpha",
      invariants_triggered: ["authority-boundary"],
      completed_stages: ["signal_classification", "policy_routing"],
      explanation_available: true,
      audit_recorded: true,
      provenance_summary: "deterministic governance path",
      timestamp: 1710000000301,
    });

    expect(result).toEqual({
      decision_id: "dec-301",
      headline: "Governance digest: dec-301 (WARN)",
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "policy", text: "Policy route: policy.alpha" },
        { key: "invariants", text: "Invariants: authority-boundary" },
        { key: "stages", text: "Stages: signal_classification, policy_routing" },
        { key: "artifacts", text: "Artifacts: explanation=yes, audit=yes" },
        { key: "provenance", text: "Provenance: deterministic governance path" },
      ],
      timestamp: 1710000000301,
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceDigest({
      decision_id: "dec-302",
      decision: "ALLOW",
      explanation_available: false,
      audit_recorded: false,
      timestamp: 1710000000302,
    });

    expect(result.lines[1]?.text).toBe("Policy route: none");
    expect(result.lines[2]?.text).toBe("Invariants: none");
    expect(result.lines[3]?.text).toBe("Stages: none");
    expect(result.lines[4]?.text).toBe("Artifacts: explanation=no, audit=no");
    expect(result.lines[5]?.text).toBe("Provenance: deterministic governance path");
  });
});
