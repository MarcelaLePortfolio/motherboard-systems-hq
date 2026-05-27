function mapStatusToSeverity(status) {
  switch (status) {
    case "healthy":
      return "info";
    case "degraded":
      return "attention";
    case "stalled":
      return "elevated";
    case "unknown":
      return "attention";
    default:
      return "attention";
  }
}

function mapStatusToConfidence(status) {
  switch (status) {
    case "healthy":
      return "high";
    case "degraded":
      return "medium";
    case "stalled":
      return "medium";
    case "unknown":
      return "low";
    default:
      return "insufficient";
  }
}

function mapStatusToType(status) {
  switch (status) {
    case "healthy":
      return "informational";
    case "degraded":
      return "attention";
    case "stalled":
      return "elevated";
    case "unknown":
      return "attention";
    default:
      return "attention";
  }
}

function buildGuidanceId(signal) {
  return ["guidance", signal.domain, signal.key, String(signal.observedAt)].join(":");
}

function createBoundedGuidance(signal) {
  let message = `Observed ${signal.domain} signal: ${signal.summary}`;
  let rationale = "Observed signals support bounded operator visibility without execution inference.";

  if (signal.domain === "system_health" && signal.status === "healthy") {
    message = `System health is currently stable: ${signal.summary}`;
    rationale = "Observed system health signals are within acceptable bounds.";
  } else if (signal.domain === "system_health" && signal.status === "degraded") {
    message = `System health needs attention: ${signal.summary}`;
    rationale = "Observed system health signals indicate degradation without proving failure.";
  } else if (signal.domain === "system_health" && signal.status === "stalled") {
    message = `System health appears stalled: ${signal.summary}`;
    rationale = "Observed system health signals indicate a sustained non-healthy condition.";
  }

  return {
    id: buildGuidanceId(signal),
    type: mapStatusToType(signal.status),
    domain: signal.domain,
    severity: mapStatusToSeverity(signal.status),
    confidence: mapStatusToConfidence(signal.status),
    message,
    rationale,
    signalSource: [signal.source, signal.key],
    bounded: true,
    executionImpact: "none",
    createdAt: signal.observedAt,
  };
}

function sortGuidanceDeterministically(guidance) {
  return [...guidance].sort((a, b) => {
    if (a.createdAt !== b.createdAt) return a.createdAt - b.createdAt;
    if (a.domain !== b.domain) return a.domain.localeCompare(b.domain);
    if (a.severity !== b.severity) return a.severity.localeCompare(b.severity);
    return a.id.localeCompare(b.id);
  });
}

function assessSurfaceConfidence(signals) {
  if (!Array.isArray(signals) || signals.length === 0) {
    return {
      confidence: "insufficient",
      reason: "No signals available for interpretation.",
      signalCount: 0,
      conflictingSignals: false,
    };
  }

  const statuses = new Set(signals.map((signal) => signal.status));
  const hasHealthy = statuses.has("healthy");
  const hasDegraded = statuses.has("degraded");
  const hasStalled = statuses.has("stalled");
  const hasUnknown = statuses.has("unknown");

  if (hasStalled) {
    return {
      confidence: hasUnknown ? "low" : "medium",
      reason: "At least one observed signal indicates a sustained non-healthy condition.",
      signalCount: signals.length,
      conflictingSignals: hasHealthy,
    };
  }

  if (hasDegraded) {
    return {
      confidence: hasUnknown ? "low" : "medium",
      reason: "Observed signals indicate degradation without proving system failure.",
      signalCount: signals.length,
      conflictingSignals: hasHealthy,
    };
  }

  if (hasUnknown) {
    return {
      confidence: "low",
      reason: "Observed signal quality is insufficient for stronger interpretation.",
      signalCount: signals.length,
      conflictingSignals: false,
    };
  }

  return {
    confidence: "high",
    reason: "Observed signals are coherent and within acceptable bounds.",
    signalCount: signals.length,
    conflictingSignals: false,
  };
}

export function reduceSystemHealthSnapshotToGuidanceReduction(snapshot) {
  const generatedAt = Date.parse(snapshot.timestamp);
  const now = Number.isFinite(generatedAt) ? generatedAt : Date.now();

  const signals = [
    {
      key: "system-health",
      domain: "system_health",
      status: snapshot.status === "OK" ? "healthy" : "degraded",
      value: snapshot.status,
      summary: String(snapshot.situationSummary || "").split("\n")[0] || "system health snapshot available",
      observedAt: now,
      source: "diagnostics/system-health",
    },
  ];

  const guidance = sortGuidanceDeterministically(signals.map(createBoundedGuidance));
  const confidence = assessSurfaceConfidence(signals);

  return {
    envelope: {
      guidance,
      generatedAt: now,
      cognitionVersion: "phase_89",
      executionAuthority: "none",
    },
    surfaceConfidence: confidence.confidence,
    confidenceReason: confidence.reason,
    signalCount: confidence.signalCount,
    conflictingSignals: confidence.conflictingSignals,
  };
}
