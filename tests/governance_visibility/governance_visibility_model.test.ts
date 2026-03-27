import { describe, expect, it } from "vitest";
import type { GovernanceVisibilityRecord } from "../../src/governance_visibility/governance_visibility_model";

describe("governance_visibility_model", () => {
  it("supports deterministic record shape", () => {
    const record: GovernanceVisibilityRecord = {
      decision_id: "dec-001",
      signal_type: "task.created",
      policy_matched: "policy.alpha",
      decision: "WARN",
      invariants_triggered: ["authority-boundary"],
      explanation_available: true,
      audit_recorded: true,
      timestamp: 1710000000000,
    };

    expect(record.decision_id).toBe("dec-001");
    expect(record.signal_type).toBe("task.created");
    expect(record.policy_matched).toBe("policy.alpha");
    expect(record.decision).toBe("WARN");
    expect(record.invariants_triggered).toEqual(["authority-boundary"]);
    expect(record.explanation_available).toBe(true);
    expect(record.audit_recorded).toBe(true);
    expect(record.timestamp).toBe(1710000000000);
  });
});
