import { describe, expect, it } from "vitest";
import {
  formatAuditPresence,
  formatDecision,
  formatExplanationPresence,
  formatInvariantSummary,
  formatPolicySummary,
} from "../../src/governance_visibility/governance_visibility_formatter";
import type { GovernanceVisibilityRecord } from "../../src/governance_visibility/governance_visibility_model";

function makeRecord(
  overrides: Partial<GovernanceVisibilityRecord> = {},
): GovernanceVisibilityRecord {
  return {
    decision_id: "dec-001",
    signal_type: "task.created",
    policy_matched: "policy.alpha",
    decision: "ALLOW",
    invariants_triggered: ["authority-boundary", "registry-safety"],
    explanation_available: true,
    audit_recorded: true,
    timestamp: 1710000000000,
    ...overrides,
  };
}

describe("governance_visibility_formatter", () => {
  it("formats decision", () => {
    expect(formatDecision(makeRecord({ decision: "BLOCK" }))).toBe("Decision: BLOCK");
  });

  it("formats invariant summary", () => {
    expect(formatInvariantSummary(makeRecord())).toBe(
      "Invariants triggered: authority-boundary, registry-safety",
    );
  });

  it("formats invariant summary with none", () => {
    expect(formatInvariantSummary(makeRecord({ invariants_triggered: [] }))).toBe(
      "Invariants triggered: none",
    );
  });

  it("formats policy summary", () => {
    expect(formatPolicySummary(makeRecord())).toBe("Policy matched: policy.alpha");
  });

  it("formats policy summary with none", () => {
    expect(formatPolicySummary(makeRecord({ policy_matched: null }))).toBe(
      "Policy matched: none",
    );
  });

  it("formats explanation presence", () => {
    expect(formatExplanationPresence(makeRecord({ explanation_available: true }))).toBe(
      "Explanation available: yes",
    );
    expect(formatExplanationPresence(makeRecord({ explanation_available: false }))).toBe(
      "Explanation available: no",
    );
  });

  it("formats audit presence", () => {
    expect(formatAuditPresence(makeRecord({ audit_recorded: true }))).toBe(
      "Audit recorded: yes",
    );
    expect(formatAuditPresence(makeRecord({ audit_recorded: false }))).toBe(
      "Audit recorded: no",
    );
  });
});
