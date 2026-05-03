import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorLedgerCompleteness,
  formatGovernanceOperatorLedgerDecision,
  formatGovernanceOperatorLedgerHeadline,
  formatGovernanceOperatorLedgerReadiness,
  formatGovernanceOperatorLedgerSections,
  formatGovernanceOperatorLedgerVersion,
} from "../../src/governance_operator_ledger/governance_operator_ledger_formatter";

describe("governance_operator_ledger_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorLedgerHeadline("dec-2200","BLOCK"))
      .toBe("Governance operator ledger: dec-2200 (BLOCK)");
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorLedgerDecision("WARN"))
      .toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(formatGovernanceOperatorLedgerSections(["Overview","Audit"]))
      .toBe("Sections: Overview, Audit");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorLedgerSections([]))
      .toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorLedgerReadiness(true))
      .toBe("Ledger ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorLedgerCompleteness(true))
      .toBe("Ledger complete: yes");
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorLedgerVersion("1"))
      .toBe("Ledger version: 1");
  });
});
