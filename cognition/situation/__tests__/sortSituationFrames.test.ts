import { describe, expect, it } from "vitest";
import { sortSituationFrames } from "../sortSituationFrames";
import type { SituationFrame } from "../situationFrame.types";
import {
  SituationCategory,
  SituationSeverity,
} from "../situation.types";
import { ConfidenceLevel } from "../../guidance/guidance.types";

function makeFrame(
  overrides: Partial<SituationFrame> = {}
): SituationFrame {
  return {
    classification: {
      category: SituationCategory.INFO,
      severity: SituationSeverity.INFO,
      confidence: ConfidenceLevel.LOW,
    },
    title: "Situation Informational",
    summary: "Situation signals are informational with low confidence.",
    attentionLevel: "LOW",
    orderHint: 300,
    ...overrides,
  };
}

describe("sortSituationFrames", () => {
  it("sorts by orderHint ascending", () => {
    const frames = [
      makeFrame({ title: "Info", orderHint: 300 }),
      makeFrame({ title: "Critical", orderHint: 100 }),
      makeFrame({ title: "Warning", orderHint: 200 }),
    ];

    const sorted = sortSituationFrames(frames);

    expect(sorted.map((frame) => frame.title)).toEqual([
      "Critical",
      "Warning",
      "Info",
    ]);
  });

  it("uses title as deterministic tie-breaker", () => {
    const frames = [
      makeFrame({ title: "Zulu", orderHint: 200 }),
      makeFrame({ title: "Alpha", orderHint: 200 }),
    ];

    const sorted = sortSituationFrames(frames);

    expect(sorted.map((frame) => frame.title)).toEqual([
      "Alpha",
      "Zulu",
    ]);
  });

  it("uses summary as final deterministic tie-breaker", () => {
    const frames = [
      makeFrame({
        title: "Same",
        summary: "Zulu summary",
        orderHint: 200,
      }),
      makeFrame({
        title: "Same",
        summary: "Alpha summary",
        orderHint: 200,
      }),
    ];

    const sorted = sortSituationFrames(frames);

    expect(sorted.map((frame) => frame.summary)).toEqual([
      "Alpha summary",
      "Zulu summary",
    ]);
  });

  it("does not mutate the input array", () => {
    const frames = [
      makeFrame({ title: "Later", orderHint: 300 }),
      makeFrame({ title: "Sooner", orderHint: 100 }),
    ];
    const original = [...frames];

    const sorted = sortSituationFrames(frames);

    expect(frames).toEqual(original);
    expect(sorted).not.toBe(frames);
  });
});
