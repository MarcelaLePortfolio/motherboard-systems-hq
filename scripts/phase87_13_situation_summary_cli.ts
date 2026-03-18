import { getSituationSummarySnapshot } from "../src/cognition";
import type { SystemSituationSignals } from "../src/cognition";

function parseSignalsArg(raw: string | undefined): SystemSituationSignals {
  if (!raw) {
    return {};
  }

  const parsed = JSON.parse(raw) as unknown;

  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new Error("Signals argument must be a JSON object");
  }

  const candidate = parsed as Record<string, unknown>;

  return {
    stability:
      typeof candidate.stability === "string" ? candidate.stability : undefined,
    executionRisk:
      typeof candidate.executionRisk === "string"
        ? candidate.executionRisk
        : undefined,
    cognition:
      typeof candidate.cognition === "string" ? candidate.cognition : undefined,
    signalCoherence:
      typeof candidate.signalCoherence === "string"
        ? candidate.signalCoherence
        : undefined,
    operatorAttention:
      typeof candidate.operatorAttention === "string"
        ? candidate.operatorAttention
        : undefined,
  };
}

function main(): void {
  const rawSignals = process.env.SITUATION_SIGNALS_JSON ?? process.argv[2];
  const signals = parseSignalsArg(rawSignals);
  const snapshot = getSituationSummarySnapshot(signals);

  process.stdout.write(JSON.stringify(snapshot, null, 2) + "\n");
}

main();
