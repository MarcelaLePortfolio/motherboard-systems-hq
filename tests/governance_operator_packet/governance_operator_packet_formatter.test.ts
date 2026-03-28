import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorPacketArtifacts,
  formatGovernanceOperatorPacketCompleteness,
  formatGovernanceOperatorPacketDecision,
  formatGovernanceOperatorPacketHeadline,
  formatGovernanceOperatorPacketInvariants,
  formatGovernanceOperatorPacketPolicy,
  formatGovernanceOperatorPacketStages,
} from "../../src/governance_operator_packet/governance_operator_packet_formatter";

describe("governance_operator_packet_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorPacketHeadline("dec-400", "BLOCK")).toBe(
      "Governance operator packet: dec-400 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorPacketDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats policy", () => {
    expect(formatGovernanceOperatorPacketPolicy("policy.alpha")).toBe(
      "Policy route: policy.alpha",
    );
  });

  it("formats missing policy", () => {
    expect(formatGovernanceOperatorPacketPolicy(null)).toBe("Policy route: none");
  });

  it("formats invariants", () => {
    expect(
      formatGovernanceOperatorPacketInvariants(["authority-boundary", "registry-safety"]),
    ).toBe("Invariants: authority-boundary, registry-safety");
  });

  it("formats stages", () => {
    expect(
      formatGovernanceOperatorPacketStages(["signal_classification", "policy_routing"]),
    ).toBe("Stages: signal_classification, policy_routing");
  });

  it("formats artifacts", () => {
    expect(formatGovernanceOperatorPacketArtifacts(true, false)).toBe(
      "Artifacts: explanation=yes, audit=no",
    );
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorPacketCompleteness(true)).toBe(
      "Packet complete: yes",
    );
  });
});
