import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorRegister } from "../../src/governance_operator_register/governance_operator_register_builder";

describe("governance_operator_register_builder", () => {
  it("builds a deterministic governance operator register", () => {
    const result = buildGovernanceOperatorRegister({
      decision_id: "dec-1601",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001601,
    });

    expect(result).toEqual({
      headline: "Governance operator register: dec-1601 (WARN)",
      metadata: {
        decision_id: "dec-1601",
        register_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001601,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Register ready: yes" },
        { key: "complete", text: "Register complete: yes" },
        { key: "version", text: "Register version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorRegister({
      decision_id: "dec-1602",
      decision: "ALLOW",
      timestamp: 1710000001602,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Register ready: yes");
    expect(result.lines[3]?.text).toBe("Register complete: yes");
    expect(result.lines[4]?.text).toBe("Register version: 1");
  });
});
