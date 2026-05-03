import { getSituationSummary } from "./getSituationSummary";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runSmoke(): string {

  const result = getSituationSummary({

    stability: "stable",
    executionRisk: "none",
    cognition: "consistent",
    signalCoherence: "coherent",
    operatorAttention: "none"

  });

  const expected =
    "SYSTEM STABLE\n" +
    "NO EXECUTION RISK DETECTED\n" +
    "COGNITION SIGNALS CONSISTENT\n" +
    "SIGNALS COHERENT\n" +
    "NO OPERATOR ACTION REQUIRED";

  assert(
    result === expected,
    "Getter output mismatch"
  );

  return "PASS";

}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Getter smoke failed");
}
