/*
PHASE 89 — SMOKE MATRIX
Deterministic bounded operator guidance verification.
Cognition only. No execution authority.
*/

import { reduceOperatorHealthSurfaceToGuidance } from "./operatorGuidanceReducer";
import { assertOperatorGuidanceReductionSafe } from "./operatorGuidanceSafety";
import type { GuidanceSignalObservation } from "./operatorGuidanceMapping";

type SmokeCase = {
  name: string;
  signals: GuidanceSignalObservation[];
  expectedGuidanceCount: number;
  expectedSurfaceConfidence: "high" | "medium" | "low" | "insufficient";
  expectedConflictingSignals: boolean;
};

function assert(condition: unknown, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

const NOW = 1_763_600_000_000;

const SMOKE_MATRIX: SmokeCase[] = [
  {
    name: "healthy_system_health",
    signals: [
      {
        key: "system-health",
        domain: "system_health",
        status: "healthy",
        summary: "all monitored health signals nominal",
        observedAt: NOW,
        source: "health_surface",
      },
    ],
    expectedGuidanceCount: 1,
    expectedSurfaceConfidence: "high",
    expectedConflictingSignals: false,
  },
  {
    name: "degraded_throughput",
    signals: [
      {
        key: "queue-throughput",
        domain: "throughput",
        status: "degraded",
        summary: "throughput below expected range",
        observedAt: NOW + 1,
        source: "health_surface",
      },
    ],
    expectedGuidanceCount: 1,
    expectedSurfaceConfidence: "medium",
    expectedConflictingSignals: false,
  },
  {
    name: "stalled_latency",
    signals: [
      {
        key: "queue-latency",
        domain: "latency",
        status: "stalled",
        summary: "latency materially elevated",
        observedAt: NOW + 2,
        source: "health_surface",
      },
    ],
    expectedGuidanceCount: 1,
    expectedSurfaceConfidence: "medium",
    expectedConflictingSignals: false,
  },
  {
    name: "unknown_signal_quality",
    signals: [
      {
        key: "signal-quality",
        domain: "signal_quality",
        status: "unknown",
        summary: "signal visibility incomplete",
        observedAt: NOW + 3,
        source: "health_surface",
      },
    ],
    expectedGuidanceCount: 1,
    expectedSurfaceConfidence: "low",
    expectedConflictingSignals: false,
  },
  {
    name: "conflicting_healthy_and_degraded",
    signals: [
      {
        key: "system-health",
        domain: "system_health",
        status: "healthy",
        summary: "baseline health appears nominal",
        observedAt: NOW + 4,
        source: "health_surface",
      },
      {
        key: "queue-throughput",
        domain: "throughput",
        status: "degraded",
        summary: "throughput reduced",
        observedAt: NOW + 5,
        source: "health_surface",
      },
    ],
    expectedGuidanceCount: 2,
    expectedSurfaceConfidence: "medium",
    expectedConflictingSignals: true,
  },
  {
    name: "no_signals",
    signals: [],
    expectedGuidanceCount: 0,
    expectedSurfaceConfidence: "insufficient",
    expectedConflictingSignals: false,
  },
];

export function runOperatorGuidanceSmokeMatrix(): void {
  for (const testCase of SMOKE_MATRIX) {
    const reduction = reduceOperatorHealthSurfaceToGuidance({
      signals: testCase.signals,
      generatedAt: NOW + 100,
    });

    assertOperatorGuidanceReductionSafe(reduction);

    assert(
      reduction.envelope.executionAuthority === "none",
      `${testCase.name}: execution authority drift detected`,
    );

    assert(
      reduction.envelope.cognitionVersion === "phase_89",
      `${testCase.name}: cognition version drift detected`,
    );

    assert(
      reduction.envelope.guidance.length === testCase.expectedGuidanceCount,
      `${testCase.name}: expected ${testCase.expectedGuidanceCount} guidance items, received ${reduction.envelope.guidance.length}`,
    );

    assert(
      reduction.surfaceConfidence === testCase.expectedSurfaceConfidence,
      `${testCase.name}: expected surface confidence ${testCase.expectedSurfaceConfidence}, received ${reduction.surfaceConfidence}`,
    );

    assert(
      reduction.conflictingSignals === testCase.expectedConflictingSignals,
      `${testCase.name}: conflictingSignals mismatch`,
    );

    for (const guidance of reduction.envelope.guidance) {
      assert(
        guidance.bounded === true,
        `${testCase.name}: bounded flag drift detected`,
      );

      assert(
        guidance.executionImpact === "none",
        `${testCase.name}: execution impact drift detected`,
      );

      assert(
        guidance.signalSource.length > 0,
        `${testCase.name}: signalSource missing`,
      );
    }
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  runOperatorGuidanceSmokeMatrix();
  process.stdout.write("operatorGuidance smoke matrix passed\n");
}
