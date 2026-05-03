import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorRecord } from "../../src/governance_operator_record/governance_operator_record_builder";

describe("governance_operator_record_builder", () => {
  it("builds a deterministic governance operator record", () => {
    const result = buildGovernanceOperatorRecord({
      decision_id: "dec-1401",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001401,
    });

    expect(result).toEqual({
      headline: "Governance operator record: dec-1401 (WARN)",
      metadata: {
        decision_id: "dec-1401",
        record_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001401,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Record ready: yes" },
        { key: "complete", text: "Record complete: yes" },
        { key: "version", text: "Record version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorRecord({
      decision_id: "dec-1402",
      decision: "ALLOW",
      timestamp: 1710000001402,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Record ready: yes");
    expect(result.lines[3]?.text).toBe("Record complete: yes");
    expect(result.lines[4]?.text).toBe("Record version: 1");
  });
});
