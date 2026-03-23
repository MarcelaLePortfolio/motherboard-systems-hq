export type StabilityState =
  | "stable"
  | "degraded"
  | "unknown";

export type ExecutionRiskState =
  | "none"
  | "elevated"
  | "unknown";

export type CognitionState =
  | "consistent"
  | "mixed"
  | "unknown";

export type SignalCoherenceState =
  | "coherent"
  | "divergent"
  | "unknown";

export type OperatorAttentionState =
  | "none"
  | "recommended"
  | "required"
  | "unknown";

export type GovernanceCognitionState =
  | "verified"
  | "attention"
  | "unknown";

export type SituationSummaryInputs = {
  stabilityState?: StabilityState;
  executionRiskState?: ExecutionRiskState;
  cognitionState?: CognitionState;
  signalCoherenceState?: SignalCoherenceState;
  operatorAttentionState?: OperatorAttentionState;
  governanceCognitionState?: GovernanceCognitionState;
};

export type SituationSummary = {
  stabilityState: StabilityState;
  executionRiskState: ExecutionRiskState;
  cognitionState: CognitionState;
  signalCoherenceState: SignalCoherenceState;
  operatorAttentionState: OperatorAttentionState;
  governanceCognitionState: GovernanceCognitionState;
  operationalConfidence?: {
    level: "HIGH" | "MEDIUM" | "LOW" | "UNKNOWN";
    source?: "governance" | "cognition" | "signals";
  };
  summaryLines: string[];
};

function normalizeStability(
  state?: StabilityState
): StabilityState {
  return state ?? "unknown";
}

function normalizeExecutionRisk(
  state?: ExecutionRiskState
): ExecutionRiskState {
  return state ?? "unknown";
}

function normalizeCognition(
  state?: CognitionState
): CognitionState {
  return state ?? "unknown";
}

function normalizeCoherence(
  state?: SignalCoherenceState
): SignalCoherenceState {
  return state ?? "unknown";
}

function normalizeAttention(
  state?: OperatorAttentionState
): OperatorAttentionState {
  return state ?? "unknown";
}

function normalizeGovernanceCognition(
  state?: GovernanceCognitionState
): GovernanceCognitionState {
  return state ?? "unknown";
}

function stabilityLine(state: StabilityState): string {
  if (state === "stable") return "SYSTEM STABLE";
  if (state === "degraded") return "SYSTEM DEGRADED";
  return "SYSTEM STATE UNKNOWN";
}

function executionRiskLine(state: ExecutionRiskState): string {
  if (state === "none") return "NO EXECUTION RISK DETECTED";
  if (state === "elevated") return "EXECUTION RISK ELEVATED";
  return "EXECUTION RISK UNKNOWN";
}

function cognitionLine(state: CognitionState): string {
  if (state === "consistent") return "COGNITION SIGNALS CONSISTENT";
  if (state === "mixed") return "COGNITION SIGNALS MIXED";
  return "COGNITION STATE UNKNOWN";
}

function coherenceLine(state: SignalCoherenceState): string {
  if (state === "coherent") return "SIGNALS COHERENT";
  if (state === "divergent") return "SIGNALS DIVERGENT";
  return "SIGNAL COHERENCE UNKNOWN";
}

function attentionLine(state: OperatorAttentionState): string {
  if (state === "none") return "NO OPERATOR ACTION REQUIRED";
  if (state === "recommended") return "OPERATOR REVIEW RECOMMENDED";
  if (state === "required") return "OPERATOR ATTENTION REQUIRED";
  return "OPERATOR ATTENTION STATE UNKNOWN";
}

function governanceCognitionLine(state: GovernanceCognitionState): string {
  if (state === "verified") return "GOVERNANCE CONDITION VERIFIED";
  if (state === "attention") return "GOVERNANCE REVIEW RECOMMENDED";
  return "GOVERNANCE CONDITION UNKNOWN";
}

export function composeSituationSummary(
  inputs: SituationSummaryInputs
): SituationSummary {
  const stability = normalizeStability(inputs.stabilityState);
  const executionRisk = normalizeExecutionRisk(inputs.executionRiskState);
  const cognition = normalizeCognition(inputs.cognitionState);
  const coherence = normalizeCoherence(inputs.signalCoherenceState);
  const attention = normalizeAttention(inputs.operatorAttentionState);
  const governanceCognition = normalizeGovernanceCognition(
    inputs.governanceCognitionState
  );

  const summaryLines = [
    stabilityLine(stability),
    executionRiskLine(executionRisk),
    cognitionLine(cognition),
    coherenceLine(coherence),
    attentionLine(attention),
    governanceCognitionLine(governanceCognition),
  ];

  return {
    stabilityState: stability,
    executionRiskState: executionRisk,
    cognitionState: cognition,
    signalCoherenceState: coherence,
    operatorAttentionState: attention,
    governanceCognitionState: governanceCognition,
    summaryLines,
  };
}
