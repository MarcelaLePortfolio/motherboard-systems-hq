import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorSnapshot } from "../../src/governance_operator_snapshot/governance_operator_snapshot_builder";

describe("governance_operator_snapshot_builder", () => {
  it("builds a deterministic governance operator snapshot", () => {
    const result = buildGovernanceOperatorSnapshot({
      decision_id: "dec-1001",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001001,
    });

    expect(result).toEqual({
      headline: "Governance operator snapshot: dec-1001 (WARN)",
      metadata: {
        decision_id: "dec-1001",
        snapshot_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001001,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Snapshot ready: yes" },
        { key: "complete", text: "Snapshot complete: yes" },
        { key: "version", text: "Snapshot version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorSnapshot({
      decision_id: "dec-1002",
      decision: "ALLOW",
      timestamp: 1710000001002,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Snapshot ready: yes");
    expect(result.lines[3]?.text).toBe("Snapshot complete: yes");
    expect(result.lines[4]?.text).toBe("Snapshot version: 1");
  });
});
