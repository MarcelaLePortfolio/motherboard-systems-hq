import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorPacket } from "../../src/governance_operator_packet/governance_operator_packet_builder";

describe("governance_operator_packet_builder", () => {
  it("builds a deterministic governance operator packet", () => {
    const result = buildGovernanceOperatorPacket({
      decision_id: "dec-401",
      decision: "WARN",
      policy_route: "policy.alpha",
      invariants_triggered: ["authority-boundary"],
      completed_stages: ["signal_classification", "policy_routing"],
      explanation_available: true,
      audit_recorded: true,
      timestamp: 1710000000401,
    });

    expect(result).toEqual({
      headline: "Governance operator packet: dec-401 (WARN)",
      metadata: {
        decision_id: "dec-401",
        packet_version: "1",
        complete: true,
        timestamp: 1710000000401,
      },
      sections: [
        {
          title: "Overview",
          lines: [
            { key: "decision", text: "Decision: WARN" },
            { key: "policy", text: "Policy route: policy.alpha" },
          ],
        },
        {
          title: "Evaluation",
          lines: [
            { key: "invariants", text: "Invariants: authority-boundary" },
            { key: "stages", text: "Stages: signal_classification, policy_routing" },
          ],
        },
        {
          title: "Artifacts",
          lines: [
            { key: "artifacts", text: "Artifacts: explanation=yes, audit=yes" },
            { key: "complete", text: "Packet complete: yes" },
          ],
        },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorPacket({
      decision_id: "dec-402",
      decision: "ALLOW",
      explanation_available: false,
      audit_recorded: false,
      timestamp: 1710000000402,
    });

    expect(result.sections[0]?.lines[1]?.text).toBe("Policy route: none");
    expect(result.sections[1]?.lines[0]?.text).toBe("Invariants: none");
    expect(result.sections[1]?.lines[1]?.text).toBe("Stages: none");
    expect(result.sections[2]?.lines[0]?.text).toBe("Artifacts: explanation=no, audit=no");
    expect(result.sections[2]?.lines[1]?.text).toBe("Packet complete: yes");
  });
});
