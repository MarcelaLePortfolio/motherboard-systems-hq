import {
  adaptSituationSummaryInputs,
  buildRenderedSituationSummary,
  buildSituationSummary,
  getSituationSummary,
  getSituationSummarySnapshot,
  getSystemSituationSummary,
  renderSituationSummary,
} from "./index";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runSmoke(): string {
  const signals = {
    stability: "stable" as const,
    executionRisk: "none" as const,
    cognition: "consistent" as const,
    signalCoherence: "coherent" as const,
    operatorAttention: "none" as const,
  };

  const inputs = adaptSituationSummaryInputs(signals);

  assert(inputs.stabilityState === "stable", "Unexpected adapted stabilityState");
  assert(inputs.executionRiskState === "none", "Unexpected adapted executionRiskState");
  assert(inputs.cognitionState === "consistent", "Unexpected adapted cognitionState");
  assert(
    inputs.signalCoherenceState === "coherent",
    "Unexpected adapted signalCoherenceState"
  );
  assert(
    inputs.operatorAttentionState === "none",
    "Unexpected adapted operatorAttentionState"
  );
  assert(
    inputs.governanceCognitionState === "unknown",
    "Unexpected adapted governanceCognitionState"
  );

  const summary = buildSituationSummary(signals);
  const rendered = renderSituationSummary(summary);
  const builtRendered = buildRenderedSituationSummary(signals);
  const getterRendered = getSituationSummary(signals);
  const systemRendered = getSystemSituationSummary(signals);
  const snapshot = getSituationSummarySnapshot(signals);

  const expected = [
    "SYSTEM STABLE",
    "NO EXECUTION RISK DETECTED",
    "COGNITION SIGNALS CONSISTENT",
    "SIGNALS COHERENT",
    "NO OPERATOR ACTION REQUIRED",
    "GOVERNANCE CONDITION UNKNOWN",
  ].join("\n");

  assert(rendered === expected, "Rendered summary mismatch");
  assert(builtRendered === expected, "Built rendered summary mismatch");
  assert(getterRendered === expected, "Getter rendered summary mismatch");
  assert(systemRendered === expected, "System rendered summary mismatch");
  assert(snapshot.rendered === expected, "Snapshot rendered summary mismatch");
  assert(snapshot.summary.summaryLines.length === 6, "Snapshot summary line count mismatch");

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Cognition index smoke failed");
}
