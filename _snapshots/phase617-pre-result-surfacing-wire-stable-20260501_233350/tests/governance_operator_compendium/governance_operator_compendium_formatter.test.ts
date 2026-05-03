import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorCompendiumCompleteness,
  formatGovernanceOperatorCompendiumDecision,
  formatGovernanceOperatorCompendiumHeadline,
  formatGovernanceOperatorCompendiumReadiness,
  formatGovernanceOperatorCompendiumSections,
  formatGovernanceOperatorCompendiumVersion,
} from "../../src/governance_operator_compendium/governance_operator_compendium_formatter";

describe("governance_operator_compendium_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorCompendiumHeadline("dec-2900", "BLOCK")).toBe(
      "Governance operator compendium: dec-2900 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorCompendiumDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorCompendiumSections(["Overview", "Handbook", "Compendium"]),
    ).toBe("Sections: Overview, Handbook, Compendium");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorCompendiumSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorCompendiumReadiness(true)).toBe("Compendium ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorCompendiumCompleteness(true)).toBe(
      "Compendium complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorCompendiumVersion("1")).toBe("Compendium version: 1");
  });
});
