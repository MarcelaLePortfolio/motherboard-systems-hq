import { execFileSync } from "node:child_process";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runSmoke(): string {
  const output = execFileSync(
    "npx",
    [
      "tsx",
      "scripts/phase87_13_situation_summary_cli.ts",
      JSON.stringify({
        stability: "stable",
        executionRisk: "none",
        cognition: "consistent",
        signalCoherence: "coherent",
        operatorAttention: "none",
      }),
    ],
    { encoding: "utf8" }
  );

  const parsed = JSON.parse(output) as {
    summary: {
      stabilityState: string;
      executionRiskState: string;
      cognitionState: string;
      signalCoherenceState: string;
      operatorAttentionState: string;
      summaryLines: string[];
    };
    rendered: string;
  };

  assert(parsed.summary.stabilityState === "stable", "Unexpected stabilityState");
  assert(parsed.summary.executionRiskState === "none", "Unexpected executionRiskState");
  assert(parsed.summary.cognitionState === "consistent", "Unexpected cognitionState");
  assert(
    parsed.summary.signalCoherenceState === "coherent",
    "Unexpected signalCoherenceState"
  );
  assert(
    parsed.summary.operatorAttentionState === "none",
    "Unexpected operatorAttentionState"
  );

  const expectedRendered =
    "SYSTEM STABLE\n" +
    "NO EXECUTION RISK DETECTED\n" +
    "COGNITION SIGNALS CONSISTENT\n" +
    "SIGNALS COHERENT\n" +
    "NO OPERATOR ACTION REQUIRED";

  assert(parsed.rendered === expectedRendered, "Unexpected rendered output");
  assert(parsed.summary.summaryLines.length === 5, "Unexpected summaryLines length");

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Situation summary CLI smoke failed");
}
