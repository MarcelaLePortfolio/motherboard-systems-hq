# Phase 702 UI Trust Summary

Generated: Tue May  5 10:11:17 PDT 2026

## Key Findings

### 1. Matilda Chat Behavior
- Determine if chat is stubbed, partially wired, or real.
- Flag any UI implying full functionality if not true.

### 2. KPI Ambiguity
- Replace '--' with explicit states like 'unavailable', 'not reported', or 'inactive'.

### 3. Health Status Clarity
- Ensure 'Critical', 'Degraded', etc. include visible reasoning.

### 4. Agent / Subsystem Reasoning
- Add visible explanation for statuses (offline, degraded, idle, etc.).

## Extracted Signals

```
- Verify Matilda chat behavior truthfully.
## Chat / Matilda Search Results
server/worker/phase34_claim_task_id_for_test.sql:1:-- Verification-only helper: deterministically claim a specific task id.
server/api/guidance.original.mjs:17:        id: "atlas-optional-offline",
server/api/guidance.original.mjs:19:        message: "Atlas is optional and may be offline without blocking execution.",
server/routes/operator-guidance.mjs:104:      status: "degraded",
src/cognition/transport/cognitionTransport.label.ts:22:      return "Transport degraded"
src/cognition/situationSummaryComposer.ts:5:  | "degraded"
src/cognition/situationSummaryComposer.ts:100:      negative: ["degraded", "misaligned", "invalid", "failing", "risk", "critical"],
src/cognition/situationSummaryComposer.ts:110:    negative: ["degraded", "unstable", "critical", "failing"],
src/cognition/situationSummaryComposer.ts:128:    negative: ["incomplete", "degraded", "inconsistent", "fragmented"],
src/cognition/situationSummaryComposer.ts:139:      negative: ["incoherent", "conflicted", "degraded", "fragmented"],
src/cognition/situationSummaryComposer.ts:208:  if (state === "degraded") return "SYSTEM DEGRADED";
src/cognition/operatorGuidance.smoke.ts:45:    name: "degraded_throughput",
src/cognition/operatorGuidance.smoke.ts:50:        status: "degraded",
src/cognition/operatorGuidance.smoke.ts:93:    name: "conflicting_healthy_and_degraded",
src/cognition/operatorGuidance.smoke.ts:106:        status: "degraded",
src/cognition/operatorGuidance.live.ts:25:    status: "degraded",
src/cognition/situationSummaryInputAdapter.ts:17:  if (value === "degraded") return "degraded";
src/cognition/operatorGuidanceMapping.ts:11:export type GuidanceSignalStatus = "healthy" | "degraded" | "stalled" | "unknown";
src/cognition/operatorGuidanceMapping.ts:41:    case "degraded":
src/cognition/operatorGuidanceMapping.ts:54:    case "degraded":
src/cognition/operatorGuidanceMapping.ts:69:    case "degraded":
src/cognition/operatorGuidanceMapping.ts:125:    id: "system-health-degraded",
src/cognition/operatorGuidanceMapping.ts:128:      signal.domain === "system_health" && signal.status === "degraded",
src/cognition/operatorGuidanceMapping.ts:161:    id: "throughput-degraded",
src/cognition/operatorGuidanceMapping.ts:164:      signal.domain === "throughput" && signal.status === "degraded",
src/cognition/operatorGuidanceMapping.ts:185:    id: "latency-degraded",
src/cognition/operatorGuidanceMapping.ts:188:      signal.domain === "latency" && signal.status === "degraded",
src/cognition/operatorGuidanceMapping.ts:209:    id: "task-lifecycle-degraded",
src/cognition/operatorGuidanceMapping.ts:212:      signal.domain === "task_lifecycle" && signal.status === "degraded",
src/cognition/operatorGuidance.ts:67:export type CriticalGuidance = OperatorGuidanceBase & {
src/cognition/operatorGuidance.ts:75:  | CriticalGuidance;
src/cognition/getSituationSummary.degraded.smoke.ts:11:    stability: "degraded",
src/cognition/operatorGuidanceConfidence.ts:35:  const degraded = signals.filter(s => s.status === "degraded").length;
src/cognition/operatorGuidanceConfidence.ts:41:    healthy > 0 && (degraded > 0 || stalled > 0);
src/cognition/operatorGuidanceConfidence.ts:52:  if (degraded > 0) {
src/governance/governanceCognitionSelectorsProof.ts:29:  selectGovernanceCognitionCriticalSignalCount
src/governance/governanceCognitionSelectorsProof.ts:66:    selectGovernanceCognitionCriticalSignalCount(surface);
src/governance/governance_policy_engine.test.ts:37:assert(critical.decision === "block", "Critical policy must block")
src/governance/governance_advisory_contract.test.ts:51:        reasoning: "Critical severity must dominate report severity.",
src/governance/governance_enforcement_evaluator.test.ts:26:assert(critical.decision === "block", "Critical should block")
src/governance/governance_explanation_builder.test.ts:42:  "Critical governance condition detected."
src/governance/governance_advisory_consistency_guard.ts:16:  const hasCritical =
src/governance/governance_advisory_consistency_guard.ts:22:  if(hasCritical){
src/governance/governanceCognitionIntegrationHooks.ts:22:  selectGovernanceCognitionCriticalSignalCount,
src/governance/governanceCognitionIntegrationHooks.ts:31:  getCriticalSignalCount: () => number;
src/governance/governanceCognitionIntegrationHooks.ts:45:    getCriticalSignalCount: () =>
src/governance/governanceCognitionIntegrationHooks.ts:46:      selectGovernanceCognitionCriticalSignalCount(surface),
src/governance/governanceCognitionSelectors.ts:48:export function selectGovernanceCognitionCriticalSignalCount(
src/governance/governance_advisory_operator_view.ts:26:      headline: "Critical governance signals require operator review"
src/governance/governance_policy_registry.ts:48:    name: "Critical Block Policy",
1. Matilda chat status labeling.
```

## Phase 702 Direction

Proceed with UI-only patches:
- Label chat truthfully
- Replace ambiguous KPI values
- Add status explanations
- Add reasoning surfaces
