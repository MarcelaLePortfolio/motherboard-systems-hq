import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorCompendium } from "../../src/governance_operator_compendium/governance_operator_compendium_builder";

describe("governance_operator_compendium_builder", () => {
  it("builds a deterministic governance operator compendium", () => {
    const result = buildGovernanceOperatorCompendium({
      decision_id: "dec-2901",
      decision: "WARN",
      section_titles: ["Overview", "Handbook", "Compendium"],
      timestamp: 1710000002901,
    });

    expect(result).toEqual({
      headline: "Governance operator compendium: dec-2901 (WARN)",
      metadata: {
        decision_id: "dec-2901",
        compendium_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002901,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Handbook, Compendium" },
        { key: "ready", text: "Compendium ready: yes" },
        { key: "complete", text: "Compendium complete: yes" },
        { key: "version", text: "Compendium version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorCompendium({
      decision_id: "dec-2902",
      decision: "ALLOW",
      timestamp: 1710000002902,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Compendium ready: yes");
    expect(result.lines[3]?.text).toBe("Compendium complete: yes");
    expect(result.lines[4]?.text).toBe("Compendium version: 1");
  });
});
