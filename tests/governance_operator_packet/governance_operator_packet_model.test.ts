import { describe, expect, it } from "vitest";
import type { GovernanceOperatorPacketRecord } from "../../src/governance_operator_packet/governance_operator_packet_model";

describe("governance_operator_packet_model", () => {
  it("supports deterministic packet structure", () => {
    const record: GovernanceOperatorPacketRecord = {
      headline: "Governance operator packet: dec-400 (WARN)",
      metadata: {
        decision_id: "dec-400",
        packet_version: "1",
        complete: true,
        timestamp: 1710000000400,
      },
      sections: [
        {
          title: "Overview",
          lines: [{ key: "decision", text: "Decision: WARN" }],
        },
      ],
    };

    expect(record.metadata.decision_id).toBe("dec-400");
    expect(record.sections[0]?.title).toBe("Overview");
    expect(record.sections[0]?.lines[0]?.text).toBe("Decision: WARN");
  });
});
