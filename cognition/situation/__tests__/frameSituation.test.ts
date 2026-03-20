import { describe, expect, it } from "vitest";
import { frameSituation } from "../frameSituation";
import {
  SituationCategory,
  SituationSeverity,
} from "../situation.types";
import { ConfidenceLevel } from "../../guidance/guidance.types";

describe("frameSituation", () => {
  it("produces deterministic CRITICAL HEALTH frame", () => {
    const frame = frameSituation({
      category: SituationCategory.HEALTH,
      severity: SituationSeverity.CRITICAL,
      confidence: ConfidenceLevel.HIGH,
    });

    expect(frame.title).toBe("Critical System Health Risk");
    expect(frame.attentionLevel).toBe("HIGH");
    expect(frame.orderHint).toBe(100);
    expect(frame.summary).toContain("critical");
  });

  it("produces deterministic WARNING PERFORMANCE frame", () => {
    const frame = frameSituation({
      category: SituationCategory.PERFORMANCE,
      severity: SituationSeverity.WARNING,
      confidence: ConfidenceLevel.MEDIUM,
    });

    expect(frame.title).toBe("Performance Warning");
    expect(frame.attentionLevel).toBe("MEDIUM");
    expect(frame.orderHint).toBe(200);
  });

  it("produces deterministic INFO frame", () => {
    const frame = frameSituation({
      category: SituationCategory.INFO,
      severity: SituationSeverity.INFO,
      confidence: ConfidenceLevel.LOW,
    });

    expect(frame.title).toBe("Situation Informational");
    expect(frame.attentionLevel).toBe("LOW");
    expect(frame.orderHint).toBe(300);
  });
});
