import {
  buildSystemHealthSituationSummaryPayload,
} from "./systemHealthSituationSummary";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runSmoke(): string {
  const payload = buildSystemHealthSituationSummaryPayload({
    stability: "stable",
    executionRisk: "none",
    cognition: "consistent",
    signalCoherence: "coherent",
    operatorAttention: "none",
  });

  const expected =
    "SYSTEM STABLE\n" +
    "NO EXECUTION RISK DETECTED\n" +
    "COGNITION SIGNALS CONSISTENT\n" +
    "SIGNALS COHERENT\n" +
    "NO OPERATOR ACTION REQUIRED";

  assert(
    payload.situationSummary === expected,
    "System health situation summary payload mismatch"
  );

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("System health situation summary smoke failed");
}
