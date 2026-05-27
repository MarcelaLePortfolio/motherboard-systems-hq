import type {
  OperatorGuidanceConfidence,
  OperatorGuidanceDomain,
  OperatorGuidanceItem,
  OperatorGuidanceReduction,
  OperatorGuidanceRenderItem,
  OperatorGuidanceRenderModel,
  OperatorGuidanceStreamEvent,
} from "./operatorGuidance";
import {
  EMPTY_OPERATOR_GUIDANCE_REDUCTION,
  EMPTY_OPERATOR_GUIDANCE_STREAM_EVENT,
} from "./operatorGuidance";

const DOMAIN_LABELS: Record<OperatorGuidanceDomain, string> = {
  system_health: "System health",
  throughput: "Throughput",
  latency: "Latency",
  task_lifecycle: "Task lifecycle",
  signal_quality: "Signal quality",
  operator_awareness: "Operator awareness",
};

function formatTimestamp(value: number): string {
  if (!Number.isFinite(value) || value <= 0) {
    return "Not available";
  }

  return new Date(value).toLocaleString();
}

function isConfidence(value: unknown): value is OperatorGuidanceConfidence {
  return (
    value === "high" ||
    value === "medium" ||
    value === "low" ||
    value === "insufficient"
  );
}

function normalizeGuidanceItem(value: unknown): OperatorGuidanceItem | null {
  if (!value || typeof value !== "object") {
    return null;
  }

  const item = value as Record<string, unknown>;

  if (
    typeof item.id !== "string" ||
    typeof item.type !== "string" ||
    typeof item.domain !== "string" ||
    typeof item.severity !== "string" ||
    !isConfidence(item.confidence) ||
    typeof item.message !== "string" ||
    typeof item.rationale !== "string" ||
    !Array.isArray(item.signalSource) ||
    item.bounded !== true ||
    item.executionImpact !== "none" ||
    typeof item.createdAt !== "number"
  ) {
    return null;
  }

  return {
    id: item.id,
    type: item.type as OperatorGuidanceItem["type"],
    domain: item.domain as OperatorGuidanceDomain,
    severity: item.severity as OperatorGuidanceItem["severity"],
    confidence: item.confidence,
    message: item.message,
    rationale: item.rationale,
    signalSource: item.signalSource.filter(
      (entry): entry is string => typeof entry === "string",
    ),
    bounded: true,
    executionImpact: "none",
    createdAt: item.createdAt,
  };
}

export function normalizeOperatorGuidanceReduction(
  value: unknown,
): OperatorGuidanceReduction {
  if (!value || typeof value !== "object") {
    return EMPTY_OPERATOR_GUIDANCE_REDUCTION;
  }

  const raw = value as Record<string, unknown>;
  const envelope =
    raw.envelope && typeof raw.envelope === "object"
      ? (raw.envelope as Record<string, unknown>)
      : null;

  const guidance = Array.isArray(envelope?.guidance)
    ? envelope?.guidance
        .map(normalizeGuidanceItem)
        .filter((item): item is OperatorGuidanceItem => item !== null)
    : [];

  const generatedAt =
    typeof envelope?.generatedAt === "number" ? envelope.generatedAt : 0;

  return {
    envelope: {
      guidance,
      generatedAt,
      cognitionVersion:
        envelope?.cognitionVersion === "phase_89" ? "phase_89" : "phase_89",
      executionAuthority:
        envelope?.executionAuthority === "none" ? "none" : "none",
    },
    surfaceConfidence: isConfidence(raw.surfaceConfidence)
      ? raw.surfaceConfidence
      : "insufficient",
    confidenceReason:
      typeof raw.confidenceReason === "string"
        ? raw.confidenceReason
        : "No signals available for interpretation.",
    signalCount:
      typeof raw.signalCount === "number" && Number.isInteger(raw.signalCount)
        ? raw.signalCount
        : guidance.length,
    conflictingSignals:
      typeof raw.conflictingSignals === "boolean"
        ? raw.conflictingSignals
        : false,
  };
}

export function normalizeOperatorGuidanceStreamEvent(
  value: unknown,
): OperatorGuidanceStreamEvent {
  if (!value || typeof value !== "object") {
    return EMPTY_OPERATOR_GUIDANCE_STREAM_EVENT;
  }

  const raw = value as Record<string, unknown>;

  return {
    reduction: normalizeOperatorGuidanceReduction(raw.reduction),
    source:
      typeof raw.source === "string"
        ? raw.source
        : EMPTY_OPERATOR_GUIDANCE_STREAM_EVENT.source,
    ts: typeof raw.ts === "number" ? raw.ts : 0,
  };
}

function toRenderItem(item: OperatorGuidanceItem): OperatorGuidanceRenderItem {
  return {
    id: item.id,
    domainLabel: DOMAIN_LABELS[item.domain] ?? item.domain,
    severity: item.severity,
    confidence: item.confidence,
    message: item.message,
    rationale: item.rationale,
    sources: item.signalSource,
    createdAtLabel: formatTimestamp(item.createdAt),
  };
}

export function buildOperatorGuidanceRenderModel(
  event: OperatorGuidanceStreamEvent,
): OperatorGuidanceRenderModel {
  const reduction = normalizeOperatorGuidanceReduction(event.reduction);

  return {
    title: "Operator guidance",
    generatedAtLabel: formatTimestamp(reduction.envelope.generatedAt),
    surfaceConfidence: reduction.surfaceConfidence,
    confidenceReason: reduction.confidenceReason,
    signalCount: reduction.signalCount,
    conflictingSignals: reduction.conflictingSignals,
    source: event.source,
    items: reduction.envelope.guidance.map(toRenderItem),
  };
}
