import { groupGuidance, GuidanceItem } from "./guidanceGrouping.model";
import { classifyGuidanceUI } from "./guidanceUIClassification.model";
import { GuidancePriority } from "./guidancePriority.model";
import { GuidanceConfidenceTier } from "./guidanceConfidence.model";

function assertEqual(actual: unknown, expected: unknown, label: string) {
  if (actual !== expected) {
    throw new Error(`${label} failed: expected ${expected} got ${actual}`);
  }
}

function renderSnapshot(items: GuidanceItem[]): string {
  const grouped = groupGuidance(items);

  return [
    ...grouped.HEALTH.map((item) => `${item.id}:${classifyGuidanceUI(item.priority, item.confidence, item.type).label}`),
    ...grouped.RISK.map((item) => `${item.id}:${classifyGuidanceUI(item.priority, item.confidence, item.type).label}`),
    ...grouped.WORKFLOW.map((item) => `${item.id}:${classifyGuidanceUI(item.priority, item.confidence, item.type).label}`),
    ...grouped.INFORMATION.map((item) => `${item.id}:${classifyGuidanceUI(item.priority, item.confidence, item.type).label}`)
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
    id: "risk-a",
    type: "RISK",
    priority: GuidancePriority.HIGH,
    confidence: GuidanceConfidenceTier.HIGH
  },
  {
    id: "workflow-a",
    type: "WORKFLOW",
    priority: GuidancePriority.MED,
    confidence: GuidanceConfidenceTier.MED
  },
  {
    id: "info-a",
    type: "INFORMATION",
    priority: GuidancePriority.LOW,
    confidence: GuidanceConfidenceTier.LOW
  }
];

const permuted: GuidanceItem[] = [
  canonical[2],
  canonical[0],
  canonical[3],
  canonical[1]
];

const canonicalSnapshot = renderSnapshot(canonical);
const permutedSnapshot = renderSnapshot(permuted);

assertEqual(permutedSnapshot, canonicalSnapshot, "render snapshot stability");

console.log("guidanceRenderStability deterministic checks passed");
