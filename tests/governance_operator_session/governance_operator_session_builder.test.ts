import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorSession } from "../../src/governance_operator_session/governance_operator_session_builder";

describe("governance_operator_session_builder", () => {
  it("builds a deterministic governance operator session", () => {
    const result = buildGovernanceOperatorSession({
      decision_id: "dec-901",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000000901,
    });

    expect(result).toEqual({
      headline: "Governance operator session: dec-901 (WARN)",
      metadata: {
        decision_id: "dec-901",
        session_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000901,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Session ready: yes" },
        { key: "complete", text: "Session complete: yes" },
        { key: "version", text: "Session version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorSession({
      decision_id: "dec-902",
      decision: "ALLOW",
      timestamp: 1710000000902,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Session ready: yes");
    expect(result.lines[3]?.text).toBe("Session complete: yes");
    expect(result.lines[4]?.text).toBe("Session version: 1");
  });
});
