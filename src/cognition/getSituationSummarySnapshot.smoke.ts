import { getSituationSummarySnapshot } from "./getSituationSummarySnapshot";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runSmoke(): string {
  const snapshot = getSituationSummarySnapshot({
    stability: "stable",
    executionRisk: "none",
    cognition: "consistent",
    signalCoherence: "coherent",
    operatorAttention: "none",
  });

  assert(!!snapshot.summary, "Snapshot summary missing");
  assert(typeof snapshot.rendered === "string", "Snapshot rendered output missing");

  assert(snapshot.summary.stabilityState === "stable", "Unexpected stabilityState");
  assert(snapshot.summary.executionRiskState === "none", "Unexpected executionRiskState");
  assert(snapshot.summary.cognitionState === "consistent", "Unexpected cognitionState");
  assert(
    snapshot.summary.signalCoherenceState === "coherent",
    "Unexpected signalCoherenceState"
  );
  assert(
    snapshot.summary.operatorAttentionState === "none",
    "Unexpected operatorAttentionState"
  );

  const expectedRendered =
    "SYSTEM STABLE\n" +
    "NO EXECUTION RISK DETECTED\n" +
    "COGNITION SIGNALS CONSISTENT\n" +
    "SIGNALS COHERENT\n" +
    "NO OPERATOR ACTION REQUIRED";

  assert(snapshot.rendered === expectedRendered, "Snapshot rendered output mismatch");

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Situation summary snapshot smoke failed");
}
