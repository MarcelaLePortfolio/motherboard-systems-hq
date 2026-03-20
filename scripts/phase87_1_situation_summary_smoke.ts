import {
  composeSituationSummary,
  type SituationSummary,
} from "../src/cognition/situationSummaryComposer";

function assertEqual<T>(actual: T, expected: T, label: string): void {
  if (actual !== expected) {
    throw new Error(
      `${label} mismatch\nexpected: ${String(expected)}\nactual: ${String(actual)}`
    );
  }
}

function assertArrayEqual(
  actual: string[],
  expected: string[],
  label: string
): void {
  if (actual.length !== expected.length) {
    throw new Error(
      `${label} length mismatch\nexpected: ${expected.length}\nactual: ${actual.length}`
    );
  }

  for (let index = 0; index < expected.length; index += 1) {
    if (actual[index] !== expected[index]) {
      throw new Error(
        `${label}[${index}] mismatch\nexpected: ${expected[index]}\nactual: ${actual[index]}`
      );
    }
  }
}

function assertSituationSummaryEqual(
  actual: SituationSummary,
  expected: SituationSummary,
  label: string
): void {
  assertEqual(actual.stabilityState, expected.stabilityState, `${label}.stabilityState`);
  assertEqual(
    actual.executionRiskState,
    expected.executionRiskState,
    `${label}.executionRiskState`
  );
  assertEqual(actual.cognitionState, expected.cognitionState, `${label}.cognitionState`);
  assertEqual(
    actual.signalCoherenceState,
    expected.signalCoherenceState,
    `${label}.signalCoherenceState`
  );
  assertEqual(
    actual.operatorAttentionState,
    expected.operatorAttentionState,
    `${label}.operatorAttentionState`
  );
  assertArrayEqual(actual.summaryLines, expected.summaryLines, `${label}.summaryLines`);
}

function testStableInputs(): void {
  const actual = composeSituationSummary({
    stabilityState: "stable",
    executionRiskState: "none",
    cognitionState: "consistent",
    signalCoherenceState: "coherent",
    operatorAttentionState: "none",
  });

  const expected: SituationSummary = {
    stabilityState: "stable",
    executionRiskState: "none",
    cognitionState: "consistent",
    signalCoherenceState: "coherent",
    operatorAttentionState: "none",
    summaryLines: [
      "SYSTEM STABLE",
      "NO EXECUTION RISK DETECTED",
      "COGNITION SIGNALS CONSISTENT",
      "SIGNALS COHERENT",
      "NO OPERATOR ACTION REQUIRED",
    ],
  };

  assertSituationSummaryEqual(actual, expected, "testStableInputs");
}

function testUnknownFallbacks(): void {
  const actual = composeSituationSummary({});

  const expected: SituationSummary = {
    stabilityState: "unknown",
    executionRiskState: "unknown",
    cognitionState: "unknown",
    signalCoherenceState: "unknown",
    operatorAttentionState: "unknown",
    summaryLines: [
      "SYSTEM STATE UNKNOWN",
      "EXECUTION RISK UNKNOWN",
      "COGNITION STATE UNKNOWN",
      "SIGNAL COHERENCE UNKNOWN",
      "OPERATOR ATTENTION STATE UNKNOWN",
    ],
  };

  assertSituationSummaryEqual(actual, expected, "testUnknownFallbacks");
}

function testRequiredAttention(): void {
  const actual = composeSituationSummary({
    operatorAttentionState: "required",
  });

  assertEqual(
    actual.summaryLines[4],
    "OPERATOR ATTENTION REQUIRED",
    "testRequiredAttention.summaryLines[4]"
  );
}

function testDeterministicOrdering(): void {
  const input = {
    stabilityState: "degraded" as const,
    executionRiskState: "elevated" as const,
    cognitionState: "mixed" as const,
    signalCoherenceState: "divergent" as const,
    operatorAttentionState: "recommended" as const,
  };

  const first = composeSituationSummary(input);
  const second = composeSituationSummary(input);
  const third = composeSituationSummary(input);

  assertSituationSummaryEqual(first, second, "testDeterministicOrdering.firstSecond");
  assertSituationSummaryEqual(second, third, "testDeterministicOrdering.secondThird");

  assertArrayEqual(
    first.summaryLines,
    [
      "SYSTEM DEGRADED",
      "EXECUTION RISK ELEVATED",
      "COGNITION SIGNALS MIXED",
      "SIGNALS DIVERGENT",
      "OPERATOR REVIEW RECOMMENDED",
    ],
    "testDeterministicOrdering.summaryLines"
  );
}

function main(): void {
  testStableInputs();
  testUnknownFallbacks();
  testRequiredAttention();
  testDeterministicOrdering();
  console.log("phase87_1_situation_summary_smoke: PASS");
}

main();
