import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorConsoleCompleteness,
  formatGovernanceOperatorConsoleDecision,
  formatGovernanceOperatorConsoleHeadline,
  formatGovernanceOperatorConsoleReadiness,
  formatGovernanceOperatorConsoleSections,
  formatGovernanceOperatorConsoleVersion,
} from "../../src/governance_operator_console/governance_operator_console_formatter";

describe("governance_operator_console_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorConsoleHeadline("dec-700", "BLOCK")).toBe(
      "Governance operator console: dec-700 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorConsoleDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorConsoleSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorConsoleSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorConsoleReadiness(true)).toBe("Console ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorConsoleCompleteness(true)).toBe(
      "Console complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorConsoleVersion("1")).toBe("Console version: 1");
  });
});
