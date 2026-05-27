import { computePriorityScore, derivePriority } from "./guidancePriority.model";
import { GuidancePriority } from "./guidancePriority.model";

function assertEqual(actual: unknown, expected: unknown, label: string) {
  if (actual !== expected) {
    throw new Error(`${label} failed: expected ${expected} got ${actual}`);
  }
}

assertEqual(computePriorityScore("HIGH","HIGH"), 9, "HIGH/HIGH score");
assertEqual(computePriorityScore("HIGH","LOW"), 7, "HIGH/LOW score");
assertEqual(computePriorityScore("MED","MED"), 6, "MED/MED score");
assertEqual(computePriorityScore("LOW","LOW"), 3, "LOW/LOW score");

assertEqual(derivePriority("HIGH","HIGH"), GuidancePriority.HIGH, "HIGH/HIGH priority");
assertEqual(derivePriority("HIGH","LOW"), GuidancePriority.HIGH, "HIGH/LOW priority");
assertEqual(derivePriority("MED","MED"), GuidancePriority.MED, "MED/MED priority");
assertEqual(derivePriority("LOW","LOW"), GuidancePriority.LOW, "LOW/LOW priority");

console.log("guidancePriority deterministic checks passed");
