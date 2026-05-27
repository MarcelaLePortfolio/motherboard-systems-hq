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
      "scripts/phase87_17_system_situation_summary_cli.ts",
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

  const expected =
    "SYSTEM STABLE\n" +
    "NO EXECUTION RISK DETECTED\n" +
    "COGNITION SIGNALS CONSISTENT\n" +
    "SIGNALS COHERENT\n" +
    "NO OPERATOR ACTION REQUIRED\n";

  assert(output === expected, "System situation summary CLI output mismatch");

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("System situation summary CLI smoke failed");
}
