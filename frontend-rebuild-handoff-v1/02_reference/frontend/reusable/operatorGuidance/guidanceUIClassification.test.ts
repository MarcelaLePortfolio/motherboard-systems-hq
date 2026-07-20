import { classifyGuidanceUI } from "./guidanceUIClassification.model";
import { GuidancePriority } from "./guidancePriority.model";
import { GuidanceConfidenceTier } from "./guidanceConfidence.model";

function assertEqual(actual: unknown, expected: unknown, label: string) {
  if (actual !== expected) {
    throw new Error(`${label} failed`);
  }
}

const critical = classifyGuidanceUI(
  GuidancePriority.HIGH,
  GuidanceConfidenceTier.HIGH,
  "RISK"
);

assertEqual(critical.label, "CRITICAL_WARNING", "critical classification");

const caution = classifyGuidanceUI(
  GuidancePriority.MED,
  GuidanceConfidenceTier.MED,
  "WORKFLOW"
);

assertEqual(caution.label, "CAUTION", "caution classification");

const info = classifyGuidanceUI(
  GuidancePriority.LOW,
  GuidanceConfidenceTier.LOW,
  "INFORMATION"
);

assertEqual(info.label, "INFORMATIONAL", "info classification");

console.log("guidanceUIClassification deterministic checks passed");
