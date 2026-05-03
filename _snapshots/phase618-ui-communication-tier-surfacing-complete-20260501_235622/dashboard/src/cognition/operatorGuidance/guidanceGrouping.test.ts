import { groupGuidance, GuidanceItem } from "./guidanceGrouping.model";
import { GuidancePriority } from "./guidancePriority.model";
import { GuidanceConfidenceTier } from "./guidanceConfidence.model";

function assert(condition: boolean, label: string) {
  if (!condition) {
    throw new Error(label);
  }
}

const sample: GuidanceItem[] = [
  { id: "b", type: "HEALTH", priority: GuidancePriority.MED, confidence: GuidanceConfidenceTier.HIGH },
  { id: "a", type: "HEALTH", priority: GuidancePriority.HIGH, confidence: GuidanceConfidenceTier.MED },
  { id: "c", type: "RISK", priority: GuidancePriority.LOW, confidence: GuidanceConfidenceTier.LOW },
  { id: "d", type: "WORKFLOW", priority: GuidancePriority.HIGH, confidence: GuidanceConfidenceTier.VERY_HIGH }
];

const grouped = groupGuidance(sample);

assert(grouped.HEALTH.length === 2, "HEALTH count");
assert(grouped.RISK.length === 1, "RISK count");
assert(grouped.WORKFLOW.length === 1, "WORKFLOW count");

assert(grouped.HEALTH[0].id === "a", "priority ordering");
assert(grouped.HEALTH[1].id === "b", "secondary ordering");

console.log("guidanceGrouping deterministic checks passed");
