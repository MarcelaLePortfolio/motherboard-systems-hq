import { describe, expect, it } from "vitest";
import {
  formatDecisionTraceHeadline,
  formatDecisionTraceInvariants,
  formatDecisionTracePolicy,
  formatDecisionTraceProvenance,
  formatDecisionTraceStages,
} from "../../src/governance_traceability/governance_traceability_formatter";
import type { GovernanceTraceabilityRecord } from "../../src/governance_traceability/governance_traceability_model";

function makeRecord(
  overrides: Partial<GovernanceTraceabilityRecord> = {},
): GovernanceTraceabilityRecord {
  return {
    decision_id: "dec-100",
    signal_type: "task.started",
    policy_route: "policy.alpha",
    decision: "ALLOW",
    invariants_triggered: ["authority-boundary", "registry-safety"],
    completed_stages: ["signal_classification", "policy_routing"],
    explanation_available: true,
    audit_recorded: true,
    provenance_summary: "deterministic governance path",
    timestamp: 1710000000100,
    ...overrides,
  };
}

describe("governance_traceability_formatter", () => {
  it("formats headline", () => {
    expect(formatDecisionTraceHeadline(makeRecord({ decision: "BLOCK" }))).toBe(
      "Decision trace: dec-100 (BLOCK)",
    );
  });

  it("formats stages", () => {
    expect(formatDecisionTraceStages(makeRecord())).toBe(
      "Completed stages: signal_classification, policy_routing",
    );
  });

  it("formats stages with none", () => {
    expect(formatDecisionTraceStages(makeRecord({ completed_stages: [] }))).toBe(
      "Completed stages: none",
    );
  });

  it("formats policy route", () => {
    expect(formatDecisionTracePolicy(makeRecord())).toBe(
      "Policy route: policy.alpha",
    );
  });

  it("formats policy route with none", () => {
    expect(formatDecisionTracePolicy(makeRecord({ policy_route: null }))).toBe(
      "Policy route: none",
    );
  });

  it("formats invariants", () => {
    expect(formatDecisionTraceInvariants(makeRecord())).toBe(
      "Invariants triggered: authority-boundary, registry-safety",
    );
  });

  it("formats provenance", () => {
    expect(formatDecisionTraceProvenance(makeRecord())).toBe(
      "Provenance: deterministic governance path",
    );
  });
});
