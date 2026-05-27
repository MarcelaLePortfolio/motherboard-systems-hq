/*
PHASE 89 — LIVE VERIFICATION
Deterministic local verification harness for bounded operator guidance.
Cognition only. No execution authority.
*/

import { reduceOperatorHealthSurfaceToGuidance } from "./operatorGuidanceReducer";
import { assertOperatorGuidanceReductionSafe } from "./operatorGuidanceSafety";
import type { GuidanceSignalObservation } from "./operatorGuidanceMapping";

const NOW = 1_763_600_100_000;

const LIVE_VERIFICATION_SIGNALS: GuidanceSignalObservation[] = [
  {
    key: "system-health",
    domain: "system_health",
    status: "healthy",
    summary: "core health signals nominal",
    observedAt: NOW,
    source: "health_surface",
  },
  {
    key: "queue-throughput",
    domain: "throughput",
    status: "degraded",
    summary: "throughput below expected range",
    observedAt: NOW + 1,
    source: "health_surface",
  },
  {
    key: "queue-latency",
    domain: "latency",
    status: "stalled",
    summary: "latency materially elevated",
    observedAt: NOW + 2,
    source: "health_surface",
  },
  {
    key: "signal-quality",
    domain: "signal_quality",
    status: "unknown",
    summary: "signal visibility incomplete",
    observedAt: NOW + 3,
    source: "health_surface",
  },
];

export type OperatorGuidanceLiveVerificationResult = {
  ok: true;
  generatedAt: number;
  guidanceCount: number;
  surfaceConfidence: "high" | "medium" | "low" | "insufficient";
  conflictingSignals: boolean;
  guidanceIds: string[];
};

export function runOperatorGuidanceLiveVerification(): OperatorGuidanceLiveVerificationResult {
  const reduction = reduceOperatorHealthSurfaceToGuidance({
    signals: LIVE_VERIFICATION_SIGNALS,
    generatedAt: NOW + 100,
  });

  assertOperatorGuidanceReductionSafe(reduction);

  return {
    ok: true,
    generatedAt: reduction.envelope.generatedAt,
    guidanceCount: reduction.envelope.guidance.length,
    surfaceConfidence: reduction.surfaceConfidence,
    conflictingSignals: reduction.conflictingSignals,
    guidanceIds: reduction.envelope.guidance.map((guidance) => guidance.id),
  };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const result = runOperatorGuidanceLiveVerification();
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}
