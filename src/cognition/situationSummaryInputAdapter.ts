import type { GovernanceAwarenessSurface } from "../../shared/types/governance";
import type { SituationSummaryInputs } from "./situationSummaryComposer";

export type SystemSituationSignals = {
  stability?: string;
  executionRisk?: string;
  cognition?: string;
  signalCoherence?: string;
  operatorAttention?: string;
  governanceAwareness?: GovernanceAwarenessSurface;
};

function normalizeStability(
  value?: string
): SituationSummaryInputs["stabilityState"] {
  if (value === "stable") return "stable";
  if (value === "degraded") return "degraded";
  return "unknown";
}

function normalizeExecutionRisk(
  value?: string
): SituationSummaryInputs["executionRiskState"] {
  if (value === "none") return "none";
  if (value === "elevated") return "elevated";
  return "unknown";
}

function normalizeCognition(
  value?: string
): SituationSummaryInputs["cognitionState"] {
  if (value === "consistent") return "consistent";
  if (value === "mixed") return "mixed";
  return "unknown";
}

function normalizeSignalCoherence(
  value?: string
): SituationSummaryInputs["signalCoherenceState"] {
  if (value === "coherent") return "coherent";
  if (value === "divergent") return "divergent";
  return "unknown";
}

function normalizeOperatorAttention(
  value?: string
): SituationSummaryInputs["operatorAttentionState"] {
  if (value === "none") return "none";
  if (value === "recommended") return "recommended";
  if (value === "required") return "required";
  return "unknown";
}

function isBoolean(value: unknown): value is boolean {
  return typeof value === "boolean";
}

function isString(value: unknown): value is string {
  return typeof value === "string";
}

function isFiniteNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function hasGovernanceAwarenessStructure(
  value: unknown
): value is GovernanceAwarenessSurface["structure"] {
  if (!isRecord(value)) return false;

  return (
    isBoolean(value.capabilityRegistryVisible) &&
    isBoolean(value.workerAuthorityModelVisible) &&
    isBoolean(value.permissionAuthorityModelVisible)
  );
}

function hasGovernanceAwarenessSignal(
  value: unknown
): value is GovernanceAwarenessSurface["signals"]["governanceAwarenessSignals"][number] {
  if (!isRecord(value)) return false;

  return (
    isString(value.name) &&
    isBoolean(value.active) &&
    isString(value.summary)
  );
}

function hasGovernanceAwarenessSignals(
  value: unknown
): value is GovernanceAwarenessSurface["signals"] {
  if (!isRecord(value)) return false;
  if (!Array.isArray(value.governanceAwarenessSignals)) return false;

  return value.governanceAwarenessSignals.every(hasGovernanceAwarenessSignal);
}

function hasBoundarySummary(
  value: unknown
): value is { visible: boolean; summary: string } {
  if (!isRecord(value)) return false;

  return isBoolean(value.visible) && isString(value.summary);
}

function hasGovernanceAuthorityBoundaryAwareness(
  value: unknown
): value is GovernanceAwarenessSurface["authorityBoundaries"] {
  if (!isRecord(value)) return false;

  return (
    hasBoundarySummary(value.workerAuthorityBoundary) &&
    hasBoundarySummary(value.permissionAuthorityBoundary)
  );
}

function hasGovernanceVerificationSummary(
  value: unknown
): value is GovernanceAwarenessSurface["verification"] {
  if (!isRecord(value)) return false;

  return (
    isBoolean(value.isVerified) &&
    isString(value.lastVerifiedAt) &&
    isFiniteNumber(value.invariantTotal) &&
    isFiniteNumber(value.invariantFailures)
  );
}

export function isGovernanceAwarenessSurface(
  value: unknown
): value is GovernanceAwarenessSurface {
  if (!isRecord(value)) return false;

  return (
    hasGovernanceAwarenessStructure(value.structure) &&
    hasGovernanceAwarenessSignals(value.signals) &&
    hasGovernanceAuthorityBoundaryAwareness(value.authorityBoundaries) &&
    hasGovernanceVerificationSummary(value.verification)
  );
}

export function sanitizeGovernanceAwarenessSurface(
  value?: GovernanceAwarenessSurface
): GovernanceAwarenessSurface | undefined {
  if (!value) return undefined;
  return isGovernanceAwarenessSurface(value) ? value : undefined;
}

export function adaptSituationSummaryInputs(
  signals: SystemSituationSignals
): SituationSummaryInputs {
  const governanceAwareness = sanitizeGovernanceAwarenessSurface(
    signals.governanceAwareness
  );

  void governanceAwareness;

  return {
    stabilityState: normalizeStability(signals.stability),
    executionRiskState: normalizeExecutionRisk(signals.executionRisk),
    cognitionState: normalizeCognition(signals.cognition),
    signalCoherenceState: normalizeSignalCoherence(signals.signalCoherence),
    operatorAttentionState: normalizeOperatorAttention(signals.operatorAttention),
  };
}
