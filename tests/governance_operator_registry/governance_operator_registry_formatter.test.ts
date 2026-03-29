import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorRegistryCompleteness,
  formatGovernanceOperatorRegistryDecision,
  formatGovernanceOperatorRegistryHeadline,
  formatGovernanceOperatorRegistryReadiness,
  formatGovernanceOperatorRegistrySections,
  formatGovernanceOperatorRegistryVersion,
} from "../../src/governance_operator_registry/governance_operator_registry_formatter";

describe("governance_operator_registry_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorRegistryHeadline("dec-2300", "BLOCK")).toBe(
      "Governance operator registry: dec-2300 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorRegistryDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorRegistrySections(["Overview", "Audit", "Ledger"]),
    ).toBe("Sections: Overview, Audit, Ledger");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorRegistrySections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorRegistryReadiness(true)).toBe("Registry ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorRegistryCompleteness(true)).toBe(
      "Registry complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorRegistryVersion("1")).toBe("Registry version: 1");
  });
});
