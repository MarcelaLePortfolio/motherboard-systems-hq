from pathlib import Path
import re
import sys

path = Path("src/cognition/situationSummaryComposer.ts")
text = path.read_text()

import_line = 'import { synthesizeOperationalConfidence, type OperationalConfidence } from "./confidence";\n'
if import_line not in text:
    text = import_line + text

if "type SituationConfidenceStateValue" not in text:
    helper_block = '''
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

'''
    marker = "export interface SituationSummary"
    if marker not in text:
        sys.exit("Could not find SituationSummary interface marker.")
    text = text.replace(marker, helper_block + marker, 1)

text = re.sub(
    r'(governanceCognitionState:\s*GovernanceCognitionState;\n)',
    r'\1  operationalConfidence?: OperationalConfidence;\n',
    text,
    count=1,
)

return_pattern = re.compile(r'(\n\s*governanceCognitionState,\n)(\s*summaryLines,\n\s*};)')
if "operationalConfidence:" not in text:
    if not return_pattern.search(text):
        sys.exit("Could not find return object block for situation summary.")
    text = return_pattern.sub(
        r'\1'
        r'    operationalConfidence: buildSituationOperationalConfidence({\n'
        r'      stabilityState,\n'
        r'      executionRiskState,\n'
        r'      cognitionState,\n'
        r'      signalCoherenceState,\n'
        r'      governanceCognitionState,\n'
        r'    }),\n'
        r'\2',
        text,
        count=1,
    )

path.write_text(text)
