import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorRegistry } from "../../src/governance_operator_registry/governance_operator_registry_builder";

describe("governance_operator_registry_builder", () => {
  it("builds a deterministic governance operator registry", () => {
    const result = buildGovernanceOperatorRegistry({
      decision_id: "dec-2301",
      decision: "WARN",
      section_titles: ["Overview", "Audit", "Ledger"],
      timestamp: 1710000002301,
    });

    expect(result).toEqual({
      headline: "Governance operator registry: dec-2301 (WARN)",
      metadata: {
        decision_id: "dec-2301",
        registry_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002301,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Audit, Ledger" },
        { key: "ready", text: "Registry ready: yes" },
        { key: "complete", text: "Registry complete: yes" },
        { key: "version", text: "Registry version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorRegistry({
      decision_id: "dec-2302",
      decision: "ALLOW",
      timestamp: 1710000002302,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Registry ready: yes");
    expect(result.lines[3]?.text).toBe("Registry complete: yes");
    expect(result.lines[4]?.text).toBe("Registry version: 1");
  });
});
