import { describe, expect, it } from "vitest";
import { buildGovernanceReport } from "../../src/governance_reporting/governance_reporting_builder";

describe("governance_reporting_builder", () => {
  it("builds a deterministic governance report", () => {
    const result = buildGovernanceReport({
      decision_id: "dec-201",
      decision: "WARN",
      policy_route: "policy.alpha",
      invariants_triggered: ["authority-boundary"],
      completed_stages: ["signal_classification", "policy_routing"],
      explanation_available: true,
      audit_recorded: true,
      provenance_summary: "deterministic governance path",
      timestamp: 1710000000201,
    });

    expect(result).toEqual({
      decision_id: "dec-201",
      headline: "Governance report: dec-201 (WARN)",
      sections: [
        {
          title: "Decision Summary",
          lines: [
            { label: "decision", value: "Decision: WARN" },
            { label: "policy", value: "Policy route: policy.alpha" },
          ],
        },
        {
          title: "Evaluation Summary",
          lines: [
            {
              label: "invariants",
              value: "Invariants triggered: authority-boundary",
            },
            {
              label: "stages",
              value: "Completed stages: signal_classification, policy_routing",
            },
          ],
        },
        {
          title: "Artifact Summary",
          lines: [
            { label: "explanation", value: "Explanation available: yes" },
            { label: "audit", value: "Audit recorded: yes" },
            {
              label: "provenance",
              value: "Provenance: deterministic governance path",
            },
          ],
        },
      ],
      timestamp: 1710000000201,
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceReport({
      decision_id: "dec-202",
      decision: "ALLOW",
      explanation_available: false,
      audit_recorded: false,
      timestamp: 1710000000202,
    });

    expect(result.sections[0]?.lines[1]?.value).toBe("Policy route: none");
    expect(result.sections[1]?.lines[0]?.value).toBe("Invariants triggered: none");
    expect(result.sections[1]?.lines[1]?.value).toBe("Completed stages: none");
    expect(result.sections[2]?.lines[2]?.value).toBe(
      "Provenance: deterministic governance path",
    );
  });
});
