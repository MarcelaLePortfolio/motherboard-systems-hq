import type {
  GuidanceConfidence,
  GuidanceDomain,
  GuidanceSeverity,
  OperatorGuidance,
} from "./operatorGuidance";

export type GuidanceSignalStatus = "healthy" | "degraded" | "stalled" | "unknown";

export type GuidanceSignalObservation = {
  key: string;
  domain: GuidanceDomain;
  status: GuidanceSignalStatus;
  value?: number | string | boolean | null;
  summary: string;
  observedAt: number;
  source: string;
};

export type GuidanceMappingContext = {
  now: number;
};

export type GuidanceInterpretationRule = {
  id: string;
  domain: GuidanceDomain;
  matches: (signal: GuidanceSignalObservation) => boolean;
  create: (
    signal: GuidanceSignalObservation,
    context: GuidanceMappingContext,
  ) => OperatorGuidance;
};

function mapStatusToSeverity(status: GuidanceSignalStatus): GuidanceSeverity {
  switch (status) {
    case "healthy":
      return "info";
    case "degraded":
      return "attention";
    case "stalled":
      return "elevated";
    case "unknown":
      return "attention";
  }
}

function mapStatusToConfidence(status: GuidanceSignalStatus): GuidanceConfidence {
  switch (status) {
    case "healthy":
      return "high";
    case "degraded":
      return "medium";
    case "stalled":
      return "medium";
    case "unknown":
      return "low";
  }
}

function mapStatusToType(
  status: GuidanceSignalStatus,
): OperatorGuidance["type"] {
  switch (status) {
    case "healthy":
      return "informational";
    case "degraded":
      return "attention";
    case "stalled":
      return "elevated";
    case "unknown":
      return "attention";
  }
}

function buildGuidanceId(signal: GuidanceSignalObservation): string {
  return [
    "guidance",
    signal.domain,
    signal.key,
    String(signal.observedAt),
  ].join(":");
}

function createBoundedGuidance(
  signal: GuidanceSignalObservation,
  message: string,
  rationale: string,
): OperatorGuidance {
  const severity = mapStatusToSeverity(signal.status);
  const confidence = mapStatusToConfidence(signal.status);
  const type = mapStatusToType(signal.status);

  return {
    id: buildGuidanceId(signal),
    type,
    domain: signal.domain,
    severity,
    confidence,
    message,
    rationale,
    signalSource: [signal.source, signal.key],
    bounded: true,
    executionImpact: "none",
    createdAt: signal.observedAt,
  };
}

export const GUIDANCE_INTERPRETATION_RULES: GuidanceInterpretationRule[] = [
  {
    id: "system-health-healthy",
    domain: "system_health",
    matches: (signal) =>
      signal.domain === "system_health" && signal.status === "healthy",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `System health is currently stable: ${signal.summary}`,
        "Observed system health signals are within acceptable bounds.",
      ),
  },
  {
    id: "system-health-degraded",
    domain: "system_health",
    matches: (signal) =>
      signal.domain === "system_health" && signal.status === "degraded",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `System health needs attention: ${signal.summary}`,
        "Observed system health signals indicate degradation without proving failure.",
      ),
  },
  {
    id: "system-health-stalled",
    domain: "system_health",
    matches: (signal) =>
      signal.domain === "system_health" && signal.status === "stalled",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `System health appears stalled: ${signal.summary}`,
        "Observed system health signals indicate a sustained non-healthy condition.",
      ),
  },
  {
    id: "throughput-healthy",
    domain: "throughput",
    matches: (signal) =>
      signal.domain === "throughput" && signal.status === "healthy",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `Throughput is within expected range: ${signal.summary}`,
        "Observed throughput signals do not indicate current pressure.",
      ),
  },
  {
    id: "throughput-degraded",
    domain: "throughput",
    matches: (signal) =>
      signal.domain === "throughput" && signal.status === "degraded",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `Throughput is below expected range: ${signal.summary}`,
        "Observed throughput signals indicate reduced flow without inferring root cause.",
      ),
  },
  {
    id: "throughput-stalled",
    domain: "throughput",
    matches: (signal) =>
      signal.domain === "throughput" && signal.status === "stalled",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `Throughput appears stalled: ${signal.summary}`,
        "Observed throughput signals indicate little or no forward movement.",
      ),
  },
  {
    id: "latency-degraded",
    domain: "latency",
    matches: (signal) =>
      signal.domain === "latency" && signal.status === "degraded",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `Latency is elevated: ${signal.summary}`,
        "Observed latency signals indicate slower-than-expected system response.",
      ),
  },
  {
    id: "latency-stalled",
    domain: "latency",
    matches: (signal) =>
      signal.domain === "latency" && signal.status === "stalled",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `Latency appears materially elevated: ${signal.summary}`,
        "Observed latency signals indicate a sustained delay condition.",
      ),
  },
  {
    id: "task-lifecycle-degraded",
    domain: "task_lifecycle",
    matches: (signal) =>
      signal.domain === "task_lifecycle" && signal.status === "degraded",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `Task lifecycle progression needs attention: ${signal.summary}`,
        "Observed task lifecycle signals indicate slower or uneven progression.",
      ),
  },
  {
    id: "task-lifecycle-stalled",
    domain: "task_lifecycle",
    matches: (signal) =>
      signal.domain === "task_lifecycle" && signal.status === "stalled",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `Task lifecycle progression appears stalled: ${signal.summary}`,
        "Observed task lifecycle signals indicate a sustained progression gap.",
      ),
  },
  {
    id: "signal-quality-unknown",
    domain: "signal_quality",
    matches: (signal) =>
      signal.domain === "signal_quality" && signal.status === "unknown",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `Signal quality is insufficient for strong interpretation: ${signal.summary}`,
        "Observed signal quality does not support high-confidence guidance.",
      ),
  },
  {
    id: "operator-awareness-unknown",
    domain: "operator_awareness",
    matches: (signal) =>
      signal.domain === "operator_awareness" && signal.status === "unknown",
    create: (signal) =>
      createBoundedGuidance(
        signal,
        `Operator awareness surface has incomplete visibility: ${signal.summary}`,
        "Observed awareness signals do not fully support bounded interpretation.",
      ),
  },
];

export function mapSignalToOperatorGuidance(
  signal: GuidanceSignalObservation,
  context: GuidanceMappingContext,
): OperatorGuidance | null {
  const rule = GUIDANCE_INTERPRETATION_RULES.find((candidate) =>
    candidate.matches(signal),
  );

  if (!rule) {
    return null;
  }

  return rule.create(signal, context);
}

export function mapSignalsToOperatorGuidance(
  signals: GuidanceSignalObservation[],
  context: GuidanceMappingContext,
): OperatorGuidance[] {
  return signals
    .map((signal) => mapSignalToOperatorGuidance(signal, context))
    .filter((guidance): guidance is OperatorGuidance => guidance !== null);
}
