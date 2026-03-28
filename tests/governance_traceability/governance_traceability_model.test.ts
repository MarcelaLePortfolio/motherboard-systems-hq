import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_TRACEABILITY_STAGES,
  type GovernanceTraceabilityRecord,
} from "../../src/governance_traceability/governance_traceability_model";

describe("governance_traceability_model", () => {
  it("defines deterministic stage order", () => {
    expect(GOVERNANCE_TRACEABILITY_STAGES).toEqual([
      "signal_classification",
      "policy_routing",
      "decision_pipeline",
      "invariant_evaluation",
      "explanation_capture",
      "audit_capture",
    ]);
  });

  it("supports deterministic record shape", () => {
    const record: GovernanceTraceabilityRecord = {
      decision_id: "dec-100",
      signal_type: "task.created",
      policy_route: "policy.alpha",
      decision: "WARN",
      invariants_triggered: ["authority-boundary"],
      completed_stages: ["signal_classification", "policy_routing"],
      explanation_available: true,
      audit_recorded: true,
      provenance_summary: "deterministic governance path",
      timestamp: 1710000000100,
    };

    expect(record.decision).toBe("WARN");
    expect(record.completed_stages).toEqual([
      "signal_classification",
      "policy_routing",
    ]);
  });
});
