from pathlib import Path
import re
import sys

path = Path("src/cognition/situationSummaryComposer.ts")
text = path.read_text()

import_line = 'import { synthesizeOperationalConfidence, type OperationalConfidence } from "./confidence";\n'
if import_line not in text:
    if text.startswith("import "):
        text = import_line + text
    else:
        text = import_line + "\n" + text

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

if "function buildSituationOperationalConfidence(" not in text:
    marker_match = re.search(
        r'export\s+(?:interface|type)\s+SituationSummary(?:\s*=\s*)?\s*\{',
        text,
    )
    if not marker_match:
        sys.exit("Could not find SituationSummary type marker.")
    text = text[:marker_match.start()] + helper_block + text[marker_match.start():]

if "operationalConfidence?: OperationalConfidence;" not in text:
    text, count = re.subn(
        r'(governanceCognitionState:\s*GovernanceCognitionState;\n)',
        r'\1  operationalConfidence?: OperationalConfidence;\n',
        text,
        count=1,
    )
    if count == 0:
        sys.exit("Could not add operationalConfidence field to SituationSummary.")

if "operationalConfidence: buildSituationOperationalConfidence(" not in text:
    summary_index = text.find("summaryLines,")
    if summary_index == -1:
        sys.exit("Could not locate summaryLines field in situation summary composer.")

    return_index = text.rfind("return {", 0, summary_index)
    if return_index == -1:
        sys.exit("Could not locate return object for situation summary.")

    insertion = """    operationalConfidence: buildSituationOperationalConfidence({
      stabilityState,
      executionRiskState,
      cognitionState,
      signalCoherenceState,
      governanceCognitionState,
    }),
"""
    text = text[:summary_index] + insertion + text[summary_index:]

path.write_text(text)
