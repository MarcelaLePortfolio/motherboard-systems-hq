import { synthesizeOperationalConfidence, type OperationalConfidence } from "./confidence";

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
  operationalConfidence?: {
    level: "HIGH" | "MEDIUM" | "LOW" | "UNKNOWN";
    source?: "governance" | "cognition" | "signals";
  };
};


type SituationConfidenceStateValue = string | null | undefined;

function normalizeSituationConfidenceState(
  value: SituationConfidenceStateValue,
): string {
  return String(value ?? "").trim().toLowerCase();
}

function scoreStableUnknownRiskState(
  value: SituationConfidenceStateValue,
  config: {
    readonly positive: readonly string[];
    readonly negative: readonly string[];
    readonly unknown?: readonly string[];
    readonly positiveScore: number;
    readonly negativeScore: number;
    readonly unknownScore: number;
    readonly fallbackScore: number;
  },
): number {
  const normalized = normalizeSituationConfidenceState(value);

  if (!normalized) {
    return config.unknownScore;
  }

  if ((config.unknown ?? ["unknown"]).some((token) => normalized.includes(token))) {
    return config.unknownScore;
  }

  if (config.positive.some((token) => normalized.includes(token))) {
    return config.positiveScore;
  }

  if (config.negative.some((token) => normalized.includes(token))) {
    return config.negativeScore;
  }

  return config.fallbackScore;
}

function buildSituationOperationalConfidence(args: {
  readonly stabilityState: string;
  readonly executionRiskState: string;
  readonly cognitionState: string;
  readonly signalCoherenceState: string;
  readonly governanceCognitionState: string;
}): OperationalConfidence {
  const governanceHealth = scoreStableUnknownRiskState(
    args.governanceCognitionState,
    {
      positive: ["aware", "verified", "aligned", "integrated", "healthy", "stable"],
      negative: ["degraded", "misaligned", "invalid", "failing", "risk", "critical"],
      positiveScore: 90,
      negativeScore: 35,
      unknownScore: 50,
      fallbackScore: 70,
    },
  );

  const runtimeStability = scoreStableUnknownRiskState(args.stabilityState, {
    positive: ["stable", "healthy", "normal"],
    negative: ["degraded", "unstable", "critical", "failing"],
    positiveScore: 95,
    negativeScore: 30,
    unknownScore: 50,
    fallbackScore: 70,
  });

  const runtimeRisk = scoreStableUnknownRiskState(args.executionRiskState, {
    positive: ["none", "low"],
    negative: ["medium", "high", "critical", "elevated"],
    positiveScore: 90,
    negativeScore: 35,
    unknownScore: 50,
    fallbackScore: 65,
  });

  const cognitionCompleteness = scoreStableUnknownRiskState(args.cognitionState, {
    positive: ["consistent", "complete", "clear", "healthy"],
    negative: ["incomplete", "degraded", "inconsistent", "fragmented"],
    positiveScore: 90,
    negativeScore: 35,
    unknownScore: 50,
    fallbackScore: 70,
  });

  const signalConsistency = scoreStableUnknownRiskState(
    args.signalCoherenceState,
    {
      positive: ["coherent", "consistent", "aligned", "stable"],
      negative: ["incoherent", "conflicted", "degraded", "fragmented"],
      positiveScore: 90,
      negativeScore: 35,
      unknownScore: 50,
      fallbackScore: 70,
    },
  );

  return synthesizeOperationalConfidence({
    governanceHealth: { score: governanceHealth },
    runtimeHealth: { score: Math.round((runtimeStability + runtimeRisk) / 2) },
    cognitionCompleteness: { score: cognitionCompleteness },
    signalConsistency: { score: signalConsistency },
  });
}

export type SituationSummary = {
  stabilityState: StabilityState;
  executionRiskState: ExecutionRiskState;
  cognitionState: CognitionState;
  signalCoherenceState: SignalCoherenceState;
  operatorAttentionState: OperatorAttentionState;
  governanceCognitionState: GovernanceCognitionState;
  operationalConfidence?: OperationalConfidence;
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
    operationalConfidence: inputs.operationalConfidence,
        operationalConfidence: buildSituationOperationalConfidence({
      stabilityState,
      executionRiskState,
      cognitionState,
      signalCoherenceState,
      governanceCognitionState,
    }),
summaryLines,
  };
}
