import { derivePriority } from "./guidancePriority.model";
import { deriveConfidenceTier, GuidanceConfidenceTier } from "./guidanceConfidence.model";
import { classifyGuidanceUI } from "./guidanceUIClassification.model";
import { GuidancePriority } from "./guidancePriority.model";

function assert(condition: boolean, label: string) {
  if (!condition) {
    throw new Error(label);
  }
}

const lowRiskPriority = derivePriority("LOW", "LOW");
const lowRiskConfidence = deriveConfidenceTier("LOW", "LOW");
const lowRiskUi = classifyGuidanceUI(lowRiskPriority, lowRiskConfidence, "RISK");

assert(lowRiskPriority === GuidancePriority.LOW, "low-risk priority must remain LOW");
assert(lowRiskConfidence === GuidanceConfidenceTier.LOW, "low-risk confidence must remain LOW");
assert(lowRiskUi.label === "INFORMATIONAL", "low-risk UI must remain INFORMATIONAL");

const workflowPriority = derivePriority("MED", "MED");
const workflowConfidence = deriveConfidenceTier("MED", "MED");
const workflowUi = classifyGuidanceUI(workflowPriority, workflowConfidence, "WORKFLOW");

assert(workflowPriority === GuidancePriority.MED, "workflow priority must remain MED");
assert(workflowConfidence === GuidanceConfidenceTier.HIGH, "workflow confidence must remain HIGH");
assert(workflowUi.label === "CAUTION", "workflow UI must remain CAUTION");

const highRiskPriority = derivePriority("HIGH", "HIGH");
const highRiskConfidence = deriveConfidenceTier("HIGH", "HIGH");
const highRiskUi = classifyGuidanceUI(highRiskPriority, highRiskConfidence, "RISK");

assert(highRiskPriority === GuidancePriority.HIGH, "high-risk priority must remain HIGH");
assert(highRiskConfidence === GuidanceConfidenceTier.VERY_HIGH, "high-risk confidence must remain VERY_HIGH");
assert(highRiskUi.label === "CRITICAL_WARNING", "high-risk UI must remain CRITICAL_WARNING");

console.log("guidanceSafetyConfirmation checks passed");
