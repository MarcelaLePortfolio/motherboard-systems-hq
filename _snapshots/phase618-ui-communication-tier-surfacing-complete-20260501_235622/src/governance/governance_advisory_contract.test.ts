import {
  deriveHighestSeverity,
  type GovernanceAdvisorySignal
} from "./governance_advisory_contract";

describe("deriveHighestSeverity", () => {
  it("returns none for empty signal lists", () => {
    expect(deriveHighestSeverity([])).toBe("none");
  });

  it("returns info when only info signals are present", () => {
    const signals: GovernanceAdvisorySignal[] = [
      {
        id: "sig-1",
        domain: "authority",
        severity: "info",
        summary: "Authority state nominal",
        detail: "No authority boundary concerns detected.",
        operator_guidance: "No action required.",
        reasoning: "Signal classified as informational.",
        detected_at: "2026-03-27T00:00:00.000Z",
        source: "test",
        verified: true
      }
    ];

    expect(deriveHighestSeverity(signals)).toBe("info");
  });

  it("returns the highest severity present across mixed signals", () => {
    const signals: GovernanceAdvisorySignal[] = [
      {
        id: "sig-1",
        domain: "authority",
        severity: "notice",
        summary: "Minor governance note",
        detail: "Non-blocking governance note detected.",
        operator_guidance: "Review when convenient.",
        reasoning: "Notice-level condition present.",
        detected_at: "2026-03-27T00:00:00.000Z",
        source: "test",
        verified: true
      },
      {
        id: "sig-2",
        domain: "execution_boundary",
        severity: "critical",
        summary: "Execution boundary concern",
        detail: "A critical boundary classification was provided.",
        operator_guidance: "Escalate to operator review immediately.",
        reasoning: "Critical severity must dominate report severity.",
        detected_at: "2026-03-27T00:00:01.000Z",
        source: "test",
        verified: true
      },
      {
        id: "sig-3",
        domain: "registry",
        severity: "warning",
        summary: "Registry warning",
        detail: "Warning-level registry concern detected.",
        operator_guidance: "Review registry assumptions.",
        reasoning: "Warning present but not highest.",
        detected_at: "2026-03-27T00:00:02.000Z",
        source: "test",
        verified: true
      }
    ];

    expect(deriveHighestSeverity(signals)).toBe("critical");
  });
});
