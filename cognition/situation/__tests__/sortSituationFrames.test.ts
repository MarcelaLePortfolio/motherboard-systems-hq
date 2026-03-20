import test from "node:test";
import assert from "node:assert/strict";

import { sortSituationFrames } from "../sortSituationFrames";
import type { SituationFrame } from "../situationFrame.types";
import { SituationCategory, SituationSeverity } from "../situation.types";
import { ConfidenceLevel } from "../../guidance/guidance.types";

function makeFrame(overrides: Partial<SituationFrame> = {}): SituationFrame {
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

test("sortSituationFrames sorts by orderHint ascending", () => {
  const frames = [
    makeFrame({ title: "Info", orderHint: 300 }),
    makeFrame({ title: "Critical", orderHint: 100 }),
    makeFrame({ title: "Warning", orderHint: 200 }),
  ];

  const sorted = sortSituationFrames(frames);

  assert.deepEqual(
    sorted.map((frame) => frame.title),
    ["Critical", "Warning", "Info"]
  );
});

test("sortSituationFrames uses title as deterministic tie-breaker", () => {
  const frames = [
    makeFrame({ title: "Zulu", orderHint: 200 }),
    makeFrame({ title: "Alpha", orderHint: 200 }),
  ];

  const sorted = sortSituationFrames(frames);

  assert.deepEqual(
    sorted.map((frame) => frame.title),
    ["Alpha", "Zulu"]
  );
});

test("sortSituationFrames uses summary as final deterministic tie-breaker", () => {
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

  assert.deepEqual(
    sorted.map((frame) => frame.summary),
    ["Alpha summary", "Zulu summary"]
  );
});

test("sortSituationFrames does not mutate the input array", () => {
  const frames = [
    makeFrame({ title: "Later", orderHint: 300 }),
    makeFrame({ title: "Sooner", orderHint: 100 }),
  ];
  const original = [...frames];

  const sorted = sortSituationFrames(frames);

  assert.deepEqual(frames, original);
  assert.notEqual(sorted, frames);
});
