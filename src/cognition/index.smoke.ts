import {
  adaptSituationSummaryInputs,
  buildRenderedSituationSummary,
  buildSituationSummary,
  getSituationSummary,
  getSituationSummarySnapshot,
  renderSituationSummary,
} from "./index";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runSmoke(): string {
  const signals = {
    stability: "stable",
    executionRisk: "none",
    cognition: "consistent",
    signalCoherence: "coherent",
    operatorAttention: "none",
  } as const;

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

  const summary = buildSituationSummary(signals);
  const rendered = renderSituationSummary(summary);
  const builtRendered = buildRenderedSituationSummary(signals);
  const getterRendered = getSituationSummary(signals);
  const snapshot = getSituationSummarySnapshot(signals);

  const expected =
    "SYSTEM STABLE\n" +
    "NO EXECUTION RISK DETECTED\n" +
    "COGNITION SIGNALS CONSISTENT\n" +
    "SIGNALS COHERENT\n" +
    "NO OPERATOR ACTION REQUIRED";

  assert(rendered === expected, "Rendered summary mismatch");
  assert(builtRendered === expected, "Built rendered summary mismatch");
  assert(getterRendered === expected, "Getter rendered summary mismatch");
  assert(snapshot.rendered === expected, "Snapshot rendered summary mismatch");
  assert(snapshot.summary.summaryLines.length === 5, "Snapshot summary line count mismatch");

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Cognition index smoke failed");
}
