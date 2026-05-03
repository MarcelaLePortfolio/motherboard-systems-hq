/*
PHASE 77 — SIGNAL SEVERITY MODEL

Deterministic severity scoring for operator signals.

STRICT:
READ ONLY
NO reducers
NO DB
NO telemetry mutation
NO UI mutation
NO execution authority
*/

import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";

export type SeverityLevel =
  | "NONE"
  | "LOW"
  | "MEDIUM"
  | "HIGH";

export type SignalSeverityResult = {
  replayDrift: SeverityLevel;
  healthAnomaly: SeverityLevel;
  telemetryGap: SeverityLevel;
  protectionFailure: SeverityLevel;
  reducerCollision: SeverityLevel;
  diagnosticsFailure: SeverityLevel;
  overallSeverity: SeverityLevel;
};

function severityFromBoolean(value?: boolean): SeverityLevel {
  return value ? "HIGH" : "NONE";
}

function maxSeverity(levels: SeverityLevel[]): SeverityLevel {
  if (levels.includes("HIGH")) return "HIGH";
  if (levels.includes("MEDIUM")) return "MEDIUM";
  if (levels.includes("LOW")) return "LOW";
  return "NONE";
}

export function getSignalSeverity(
  signals: OperatorSignals & {
    healthAnomaly?: boolean;
  }
): SignalSeverityResult {
  const replayDrift = severityFromBoolean(signals.replayDrift);
  const healthAnomaly = severityFromBoolean(signals.healthAnomaly);
  const telemetryGap = severityFromBoolean(signals.telemetryGap);
  const protectionFailure = severityFromBoolean(signals.protectionFailure);
  const reducerCollision = severityFromBoolean(signals.reducerCollision);
  const diagnosticsFailure = severityFromBoolean(signals.diagnosticsFailure);

  const overallSeverity = maxSeverity([
    replayDrift,
    healthAnomaly,
    telemetryGap,
    protectionFailure,
    reducerCollision,
    diagnosticsFailure
  ]);

  return {
    replayDrift,
    healthAnomaly,
    telemetryGap,
    protectionFailure,
    reducerCollision,
    diagnosticsFailure,
    overallSeverity
  };
}
