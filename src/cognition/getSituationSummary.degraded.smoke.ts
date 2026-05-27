import { getSituationSummary } from "./getSituationSummary";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runSmoke(): string {
  const result = getSituationSummary({
    stability: "degraded",
    executionRisk: "elevated",
    cognition: "mixed",
    signalCoherence: "divergent",
    operatorAttention: "required",
  });

  const expected =
    "SYSTEM DEGRADED\n" +
    "EXECUTION RISK ELEVATED\n" +
    "COGNITION SIGNALS MIXED\n" +
    "SIGNALS DIVERGENT\n" +
    "OPERATOR ATTENTION REQUIRED";

  assert(result === expected, "Degraded getter output mismatch");

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Degraded getter smoke failed");
}
