import { describe, expect, it } from "vitest";
import { buildGovernanceTraceabilitySnapshot } from "../../src/governance_traceability/governance_traceability_snapshot";

describe("governance_traceability_snapshot", () => {
  it("builds a deterministic traceability snapshot", () => {
    const result = buildGovernanceTraceabilitySnapshot({
      decision_id: "dec-101",
      signal_type: "task.started",
      policy_route: "policy.alpha",
      decision: "WARN",
      invariants_triggered: ["authority-boundary"],
      completed_stages: [
        "signal_classification",
        "policy_routing",
        "decision_pipeline",
      ],
      explanation: { present: true },
      audit: { present: true },
      provenance_summary: "deterministic governance path",
      timestamp: 1710000000101,
    });

    expect(result).toEqual({
      decision_id: "dec-101",
      signal_type: "task.started",
      policy_route: "policy.alpha",
      decision: "WARN",
      invariants_triggered: ["authority-boundary"],
      completed_stages: [
        "signal_classification",
        "policy_routing",
        "decision_pipeline",
      ],
      explanation_available: true,
      audit_recorded: true,
      provenance_summary: "deterministic governance path",
      timestamp: 1710000000101,
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceTraceabilitySnapshot({
      decision_id: "dec-102",
      signal_type: "task.completed",
      decision: "ALLOW",
      timestamp: 1710000000102,
    });

    expect(result).toEqual({
      decision_id: "dec-102",
      signal_type: "task.completed",
      policy_route: null,
      decision: "ALLOW",
      invariants_triggered: [],
      completed_stages: [],
      explanation_available: false,
      audit_recorded: false,
      provenance_summary: "deterministic governance path",
      timestamp: 1710000000102,
    });
  });

  it("copies arrays to preserve observational safety", () => {
    const invariants = ["authority-boundary"];
    const stages = ["signal_classification"] as const;

    const result = buildGovernanceTraceabilitySnapshot({
      decision_id: "dec-103",
      signal_type: "task.failed",
      decision: "BLOCK",
      invariants_triggered: invariants,
      completed_stages: stages,
      timestamp: 1710000000103,
    });

    invariants.push("registry-safety");

    expect(result.invariants_triggered).toEqual(["authority-boundary"]);
    expect(result.completed_stages).toEqual(["signal_classification"]);
  });
});
