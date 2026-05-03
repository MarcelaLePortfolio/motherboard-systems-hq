import { groupGuidance, GuidanceItem } from "./guidanceGrouping.model";
import { GuidancePriority } from "./guidancePriority.model";
import { GuidanceConfidenceTier } from "./guidanceConfidence.model";

function assertEqual(actual: unknown, expected: unknown, label: string) {
  if (actual !== expected) {
    throw new Error(`${label} failed: expected ${expected} got ${actual}`);
  }
}

function flattenIds(groups: ReturnType<typeof groupGuidance>): string {
  return [
    ...groups.HEALTH.map((item) => item.id),
    ...groups.RISK.map((item) => item.id),
    ...groups.WORKFLOW.map((item) => item.id),
    ...groups.INFORMATION.map((item) => item.id)
  ].join("|");
}

const canonical: GuidanceItem[] = [
  {
    id: "health-a",
    type: "HEALTH",
    priority: GuidancePriority.HIGH,
    confidence: GuidanceConfidenceTier.HIGH
  },
  {
    id: "health-b",
    type: "HEALTH",
    priority: GuidancePriority.MED,
    confidence: GuidanceConfidenceTier.VERY_HIGH
  },
  {
    id: "risk-a",
    type: "RISK",
    priority: GuidancePriority.HIGH,
    confidence: GuidanceConfidenceTier.MED
  },
  {
    id: "workflow-a",
    type: "WORKFLOW",
    priority: GuidancePriority.MED,
    confidence: GuidanceConfidenceTier.HIGH
  },
  {
    id: "info-a",
    type: "INFORMATION",
    priority: GuidancePriority.LOW,
    confidence: GuidanceConfidenceTier.LOW
  }
];

const reversed = [...canonical].reverse();

const shuffled: GuidanceItem[] = [
  canonical[3],
  canonical[1],
  canonical[4],
  canonical[0],
  canonical[2]
];

const canonicalOrder = flattenIds(groupGuidance(canonical));
const reversedOrder = flattenIds(groupGuidance(reversed));
const shuffledOrder = flattenIds(groupGuidance(shuffled));

assertEqual(reversedOrder, canonicalOrder, "reverse permutation stability");
assertEqual(shuffledOrder, canonicalOrder, "shuffle permutation stability");

console.log("guidanceOrdering deterministic proof passed");
