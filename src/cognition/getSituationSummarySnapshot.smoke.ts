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
  assert(
    snapshot.summary.governanceCognitionState === "unknown",
    "Unexpected governanceCognitionState"
  );

  const expectedRendered = [
    "SYSTEM STABLE",
    "NO EXECUTION RISK DETECTED",
    "COGNITION SIGNALS CONSISTENT",
    "SIGNALS COHERENT",
    "NO OPERATOR ACTION REQUIRED",
    "GOVERNANCE CONDITION UNKNOWN",
  ].join("\n");

  assert(
    snapshot.rendered === expectedRendered,
    "Snapshot rendered output mismatch"
  );

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Situation summary snapshot smoke failed");
}
