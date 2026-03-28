import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorBundle } from "../../src/governance_operator_bundle/governance_operator_bundle_builder";

describe("governance_operator_bundle_builder", () => {
  it("builds a deterministic governance operator bundle", () => {
    const result = buildGovernanceOperatorBundle({
      decision_id: "dec-1101",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001101,
    });

    expect(result).toEqual({
      headline: "Governance operator bundle: dec-1101 (WARN)",
      metadata: {
        decision_id: "dec-1101",
        bundle_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001101,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Bundle ready: yes" },
        { key: "complete", text: "Bundle complete: yes" },
        { key: "version", text: "Bundle version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorBundle({
      decision_id: "dec-1102",
      decision: "ALLOW",
      timestamp: 1710000001102,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Bundle ready: yes");
    expect(result.lines[3]?.text).toBe("Bundle complete: yes");
    expect(result.lines[4]?.text).toBe("Bundle version: 1");
  });
});
