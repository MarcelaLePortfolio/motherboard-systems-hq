import { getSituationSummary } from "./getSituationSummary";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runSmoke(): string {
  const result = getSituationSummary({});

  const expected =
    "SYSTEM STATE UNKNOWN\n" +
    "EXECUTION RISK UNKNOWN\n" +
    "COGNITION STATE UNKNOWN\n" +
    "SIGNAL COHERENCE UNKNOWN\n" +
    "OPERATOR ATTENTION STATE UNKNOWN";

  assert(result === expected, "Unknown getter output mismatch");

  return "PASS";
}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Unknown getter smoke failed");
}
