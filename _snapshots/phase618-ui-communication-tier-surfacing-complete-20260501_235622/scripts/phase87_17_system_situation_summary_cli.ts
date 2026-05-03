import { readFileSync } from "node:fs";
import { getSystemSituationSummary } from "../src/cognition";
import type { SystemSituationSignals } from "../src/cognition";

function parseSignalsArg(raw: string | undefined): SystemSituationSignals {
  if (!raw) {
    return {};
  }

  const parsed = JSON.parse(raw) as unknown;

  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new Error("Signals input must be a JSON object");
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

function readSignalsFromArgs(argv: string[]): string | undefined {
  const stdinFlagIndex = argv.indexOf("--stdin");

  if (stdinFlagIndex >= 0) {
    return readFileSync(0, "utf8").trim();
  }

  const fileFlagIndex = argv.indexOf("--file");

  if (fileFlagIndex >= 0) {
    const filePath = argv[fileFlagIndex + 1];

    if (!filePath) {
      throw new Error("Missing file path after --file");
    }

    return readFileSync(filePath, "utf8").trim();
  }

  return process.argv[2];
}

function main(): void {
  const rawSignals = readSignalsFromArgs(process.argv);
  const signals = parseSignalsArg(rawSignals);
  const rendered = getSystemSituationSummary(signals);

  process.stdout.write(rendered + "\n");
}

main();
