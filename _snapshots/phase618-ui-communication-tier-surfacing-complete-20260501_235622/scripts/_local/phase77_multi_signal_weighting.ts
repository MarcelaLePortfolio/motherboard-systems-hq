/*
PHASE 77 — MULTI-SIGNAL WEIGHTING

Deterministic weighting model for blended operator signals.

STRICT:
READ ONLY
NO reducers
NO DB
NO telemetry mutation
NO UI mutation
NO execution authority
*/

import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";

export type WeightedSignalResult = {
  replayDriftWeight: number;
  healthAnomalyWeight: number;
  telemetryGapWeight: number;
  protectionFailureWeight: number;
  reducerCollisionWeight: number;
  diagnosticsFailureWeight: number;
  totalWeight: number;
  dominantSignal:
    | "replayDrift"
    | "healthAnomaly"
    | "telemetryGap"
    | "protectionFailure"
    | "reducerCollision"
    | "diagnosticsFailure"
    | "none";
};

function boolWeight(value: boolean | undefined, weight: number): number {
  return value ? weight : 0;
}

export function getMultiSignalWeights(
  signals: OperatorSignals & { healthAnomaly?: boolean }
): WeightedSignalResult {
  const replayDriftWeight = boolWeight(signals.replayDrift, 90);
  const healthAnomalyWeight = boolWeight(signals.healthAnomaly, 80);
  const telemetryGapWeight = boolWeight(signals.telemetryGap, 70);
  const protectionFailureWeight = boolWeight(signals.protectionFailure, 100);
  const reducerCollisionWeight = boolWeight(signals.reducerCollision, 95);
  const diagnosticsFailureWeight = boolWeight(signals.diagnosticsFailure, 85);

  const entries: Array<[WeightedSignalResult["dominantSignal"], number]> = [
    ["replayDrift", replayDriftWeight],
    ["healthAnomaly", healthAnomalyWeight],
    ["telemetryGap", telemetryGapWeight],
    ["protectionFailure", protectionFailureWeight],
    ["reducerCollision", reducerCollisionWeight],
    ["diagnosticsFailure", diagnosticsFailureWeight]
  ];

  const totalWeight =
    replayDriftWeight +
    healthAnomalyWeight +
    telemetryGapWeight +
    protectionFailureWeight +
    reducerCollisionWeight +
    diagnosticsFailureWeight;

  const dominantSignal =
    totalWeight === 0
      ? "none"
      : entries.sort((a, b) => b[1] - a[1])[0][0];

  return {
    replayDriftWeight,
    healthAnomalyWeight,
    telemetryGapWeight,
    protectionFailureWeight,
    reducerCollisionWeight,
    diagnosticsFailureWeight,
    totalWeight,
    dominantSignal
  };
}
