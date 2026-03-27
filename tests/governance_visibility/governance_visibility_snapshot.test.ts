import { describe, expect, it } from "vitest";
import { buildGovernanceVisibilitySnapshot } from "../../src/governance_visibility/governance_visibility_snapshot";

describe("governance_visibility_snapshot", () => {
  it("builds a deterministic visibility snapshot", () => {
    const result = buildGovernanceVisibilitySnapshot({
      decision_id: "dec-001",
      signal_type: "task.started",
      policy_matched: "policy.alpha",
      decision: "WARN",
      invariants_triggered: ["authority-boundary"],
      explanation: { text: "explanation" },
      audit: { id: "audit-001" },
      timestamp: 1710000000000,
    });

    expect(result).toEqual({
      decision_id: "dec-001",
      signal_type: "task.started",
      policy_matched: "policy.alpha",
      decision: "WARN",
      invariants_triggered: ["authority-boundary"],
      explanation_available: true,
      audit_recorded: true,
      timestamp: 1710000000000,
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceVisibilitySnapshot({
      decision_id: "dec-002",
      signal_type: "task.completed",
      decision: "ALLOW",
      timestamp: 1710000000001,
    });

    expect(result).toEqual({
      decision_id: "dec-002",
      signal_type: "task.completed",
      policy_matched: null,
      decision: "ALLOW",
      invariants_triggered: [],
      explanation_available: false,
      audit_recorded: false,
      timestamp: 1710000000001,
    });
  });

  it("copies invariant arrays to preserve observational safety", () => {
    const invariants = ["authority-boundary"];
    const result = buildGovernanceVisibilitySnapshot({
      decision_id: "dec-003",
      signal_type: "task.failed",
      decision: "BLOCK",
      invariants_triggered: invariants,
      timestamp: 1710000000002,
    });

    invariants.push("registry-safety");

    expect(result.invariants_triggered).toEqual(["authority-boundary"]);
  });
});
