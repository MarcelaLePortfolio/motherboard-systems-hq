import type { SituationSummaryInputs } from "./situationSummaryComposer";

export type SystemSituationSignals = {
  stability?: string;
  executionRisk?: string;
  cognition?: string;
  signalCoherence?: string;
  operatorAttention?: string;
};

function normalizeStability(
  value?: string
): SituationSummaryInputs["stabilityState"] {
  if (value === "stable") return "stable";
  if (value === "degraded") return "degraded";
  return "unknown";
}

function normalizeExecutionRisk(
  value?: string
): SituationSummaryInputs["executionRiskState"] {
  if (value === "none") return "none";
  if (value === "elevated") return "elevated";
  return "unknown";
}

function normalizeCognition(
  value?: string
): SituationSummaryInputs["cognitionState"] {
  if (value === "consistent") return "consistent";
  if (value === "mixed") return "mixed";
  return "unknown";
}

function normalizeSignalCoherence(
  value?: string
): SituationSummaryInputs["signalCoherenceState"] {
  if (value === "coherent") return "coherent";
  if (value === "divergent") return "divergent";
  return "unknown";
}

function normalizeOperatorAttention(
  value?: string
): SituationSummaryInputs["operatorAttentionState"] {
  if (value === "none") return "none";
  if (value === "recommended") return "recommended";
  if (value === "required") return "required";
  return "unknown";
}

export function adaptSituationSummaryInputs(
  signals: SystemSituationSignals
): SituationSummaryInputs {
  return {
    stabilityState: normalizeStability(signals.stability),
    executionRiskState: normalizeExecutionRisk(signals.executionRisk),
    cognitionState: normalizeCognition(signals.cognition),
    signalCoherenceState: normalizeSignalCoherence(signals.signalCoherence),
    operatorAttentionState: normalizeOperatorAttention(signals.operatorAttention),
  };
}
