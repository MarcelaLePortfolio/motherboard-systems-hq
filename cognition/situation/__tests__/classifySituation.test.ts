import { describe, expect, it } from "vitest";
import { ConfidenceLevel } from "../../guidance/guidance.types";
import { classifySituation } from "../classifySituation";
import { SituationCategory, SituationSeverity } from "../situation.types";

describe("classifySituation", () => {
  it("returns deterministic defaults when no input is provided", () => {
    expect(classifySituation()).toEqual({
      category: SituationCategory.INFO,
      severity: SituationSeverity.INFO,
      confidence: ConfidenceLevel.LOW,
      metadata: undefined,
      signals: undefined,
    });
  });

  it("preserves explicit classification input", () => {
    expect(
      classifySituation({
        category: SituationCategory.RISK,
        severity: SituationSeverity.CRITICAL,
        confidence: ConfidenceLevel.HIGH,
        metadata: { source: "unit-test" },
        signals: ["signal-a"],
      })
    ).toEqual({
      category: SituationCategory.RISK,
      severity: SituationSeverity.CRITICAL,
      confidence: ConfidenceLevel.HIGH,
      metadata: { source: "unit-test" },
      signals: ["signal-a"],
    });
  });
});
