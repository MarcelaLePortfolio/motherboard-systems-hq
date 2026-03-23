import { buildSituationSummary } from "./buildSituationSummary";
import { renderSituationSummary } from "./renderSituationSummary";

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
    operatorAttention: "none",
  });

  const rendered = renderSituationSummary(summary);

  const expected = [
    "SYSTEM STABLE",
    "NO EXECUTION RISK DETECTED",
    "COGNITION SIGNALS CONSISTENT",
    "SIGNALS COHERENT",
    "NO OPERATOR ACTION REQUIRED",
    "GOVERNANCE CONDITION UNKNOWN",
  ].join("\n");

  assert(rendered === expected, "Rendered situation summary mismatch");

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Rendered situation summary smoke failed");
}
