import { normalizeGovernanceSignals } from "./governance_advisory_normalizer";
import type { GovernanceAdvisorySignal } from "./governance_advisory_contract";

function buildSignal(
  id: string,
  severity: GovernanceAdvisorySignal["severity"],
  ts: string
): GovernanceAdvisorySignal {

  return {
    id,
    domain: "governance_integrity",
    severity,
    summary: "test",
    detail: "test detail",
    operator_guidance: "none",
    reasoning: "test",
    detected_at: ts,
    source: "test",
    verified: true
  };
}

describe("normalizeGovernanceSignals", () => {

  it("deduplicates identical signals", () => {

    const s1 = buildSignal("1","warning","2026-03-27T00:00:00.000Z");

    const result = normalizeGovernanceSignals([s1,s1]);

    expect(result.length).toBe(1);

  });

  it("orders by severity deterministically", () => {

    const signals = [

      buildSignal("1","critical","2026-03-27T00:00:02.000Z"),
      buildSignal("2","info","2026-03-27T00:00:01.000Z"),
      buildSignal("3","warning","2026-03-27T00:00:03.000Z")

    ];

    const result = normalizeGovernanceSignals(signals);

    expect(result[0].severity).toBe("info");
    expect(result[1].severity).toBe("warning");
    expect(result[2].severity).toBe("critical");

  });

  it("orders same severity by timestamp", () => {

    const signals = [

      buildSignal("1","warning","2026-03-27T00:00:03.000Z"),
      buildSignal("2","warning","2026-03-27T00:00:01.000Z")

    ];

    const result = normalizeGovernanceSignals(signals);

    expect(result[0].detected_at).toBe("2026-03-27T00:00:01.000Z");

  });

});
