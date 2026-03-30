import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorReference } from "../../src/governance_operator_reference/governance_operator_reference_builder";

describe("governance_operator_reference_builder", () => {
  it("builds a deterministic governance operator reference", () => {
    const result = buildGovernanceOperatorReference({
      decision_id: "dec-3001",
      decision: "WARN",
      section_titles: ["Overview", "Compendium", "Reference"],
      timestamp: 1710000003001,
    });

    expect(result).toEqual({
      headline: "Governance operator reference: dec-3001 (WARN)",
      metadata: {
        decision_id: "dec-3001",
        reference_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000003001,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Compendium, Reference" },
        { key: "ready", text: "Reference ready: yes" },
        { key: "complete", text: "Reference complete: yes" },
        { key: "version", text: "Reference version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorReference({
      decision_id: "dec-3002",
      decision: "ALLOW",
      timestamp: 1710000003002,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Reference ready: yes");
    expect(result.lines[3]?.text).toBe("Reference complete: yes");
    expect(result.lines[4]?.text).toBe("Reference version: 1");
  });
});
