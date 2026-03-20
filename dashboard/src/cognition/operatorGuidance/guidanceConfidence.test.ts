import { computeConfidenceScore, deriveConfidenceTier, GuidanceConfidenceTier } from "./guidanceConfidence.model";

function assertEqual(actual: unknown, expected: unknown, label: string) {
  if (actual !== expected) {
    throw new Error(`${label} failed: expected ${expected} got ${actual}`);
  }
}

assertEqual(computeConfidenceScore("HIGH","HIGH"), 9, "HIGH/HIGH score");
assertEqual(computeConfidenceScore("HIGH","LOW"), 7, "HIGH/LOW score");
assertEqual(computeConfidenceScore("MED","MED"), 6, "MED/MED score");
assertEqual(computeConfidenceScore("LOW","LOW"), 3, "LOW/LOW score");

assertEqual(deriveConfidenceTier("HIGH","HIGH"), GuidanceConfidenceTier.VERY_HIGH, "HIGH/HIGH tier");
assertEqual(deriveConfidenceTier("HIGH","LOW"), GuidanceConfidenceTier.HIGH, "HIGH/LOW tier");
assertEqual(deriveConfidenceTier("MED","MED"), GuidanceConfidenceTier.HIGH, "MED/MED tier");
assertEqual(deriveConfidenceTier("LOW","LOW"), GuidanceConfidenceTier.LOW, "LOW/LOW tier");

console.log("guidanceConfidence deterministic checks passed");
