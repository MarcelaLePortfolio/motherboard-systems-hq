import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorSessionCompleteness,
  formatGovernanceOperatorSessionDecision,
  formatGovernanceOperatorSessionHeadline,
  formatGovernanceOperatorSessionReadiness,
  formatGovernanceOperatorSessionSections,
  formatGovernanceOperatorSessionVersion,
} from "../../src/governance_operator_session/governance_operator_session_formatter";

describe("governance_operator_session_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorSessionHeadline("dec-900", "BLOCK")).toBe(
      "Governance operator session: dec-900 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorSessionDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorSessionSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorSessionSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorSessionReadiness(true)).toBe("Session ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorSessionCompleteness(true)).toBe(
      "Session complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorSessionVersion("1")).toBe("Session version: 1");
  });
});
