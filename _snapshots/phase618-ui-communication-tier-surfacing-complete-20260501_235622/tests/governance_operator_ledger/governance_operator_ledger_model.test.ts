import { describe, expect, it } from "vitest";
import type { GovernanceOperatorLedgerRecord } from "../../src/governance_operator_ledger/governance_operator_ledger_model";

describe("governance_operator_ledger_model", () => {
  it("supports deterministic ledger structure", () => {
    const record: GovernanceOperatorLedgerRecord = {
      headline: "Governance operator ledger: dec-2200 (WARN)",
      metadata: {
        decision_id: "dec-2200",
        ledger_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002200,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2200");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
