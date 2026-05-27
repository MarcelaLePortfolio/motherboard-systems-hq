import { buildSituationSummary } from "./buildSituationSummary";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runSmoke(): string {

  const summary = buildSituationSummary({

    stability: "stable",
    executionRisk: "none",
    cognition: "consistent",
    signalCoherence: "coherent",
    operatorAttention: "none"

  });

  assert(!!summary, "Summary missing");

  assert(
    Array.isArray(summary.summaryLines),
    "Summary lines missing"
  );

  assert(
    summary.summaryLines.length === 5,
    "Unexpected summary structure"
  );

  assert(
    summary.summaryLines[0] === "SYSTEM STABLE",
    "Unexpected stability line"
  );

  assert(
    summary.summaryLines[1] === "NO EXECUTION RISK DETECTED",
    "Unexpected execution risk line"
  );

  assert(
    summary.summaryLines[2] === "COGNITION SIGNALS CONSISTENT",
    "Unexpected cognition line"
  );

  assert(
    summary.summaryLines[3] === "SIGNALS COHERENT",
    "Unexpected coherence line"
  );

  assert(
    summary.summaryLines[4] === "NO OPERATOR ACTION REQUIRED",
    "Unexpected operator attention line"
  );

  return "PASS";

}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Integration smoke failed");
}
