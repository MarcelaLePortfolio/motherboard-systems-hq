/*
PHASE 89 — SAFETY PROOF
Bounded operator guidance runtime invariants.
Cognition only. No execution authority.
*/

import type {
  GuidanceConfidence,
  GuidanceDomain,
  GuidanceSeverity,
  OperatorGuidance,
  OperatorGuidanceEnvelope,
} from "./operatorGuidance";
import type { OperatorGuidanceReduction } from "./operatorGuidanceReducer";

const ALLOWED_GUIDANCE_TYPES = new Set<OperatorGuidance["type"]>([
  "informational",
  "attention",
  "elevated",
  "critical",
]);

const ALLOWED_GUIDANCE_DOMAINS = new Set<GuidanceDomain>([
  "system_health",
  "throughput",
  "latency",
  "task_lifecycle",
  "signal_quality",
  "operator_awareness",
]);

const ALLOWED_GUIDANCE_SEVERITIES = new Set<GuidanceSeverity>([
  "info",
  "attention",
  "elevated",
  "critical",
]);

const ALLOWED_GUIDANCE_CONFIDENCE = new Set<GuidanceConfidence>([
  "high",
  "medium",
  "low",
  "insufficient",
]);

const FORBIDDEN_MESSAGE_PATTERNS = [
  /\bexecute\b/i,
  /\brun\b/i,
  /\bretry\b/i,
  /\brestart\b/i,
  /\bdelete\b/i,
  /\bremove\b/i,
  /\brepair\b/i,
  /\bfix\b/i,
  /\bpatch\b/i,
  /\bkill\b/i,
  /\bterminate\b/i,
  /\bdeploy\b/i,
  /\brollback\b/i,
  /\bmigrate\b/i,
  /\bself-authorize\b/i,
  /\bauto(?:mation)?\b/i,
];

export type OperatorGuidanceSafetyCheck = {
  ok: boolean;
  violations: string[];
};

function isFiniteTimestamp(value: number): boolean {
  return Number.isFinite(value) && value >= 0;
}

function assertSafeText(label: string, value: string, violations: string[]): void {
  const trimmed = value.trim();

  if (trimmed.length === 0) {
    violations.push(`${label} must be non-empty.`);
    return;
  }

  for (const pattern of FORBIDDEN_MESSAGE_PATTERNS) {
    if (pattern.test(trimmed)) {
      violations.push(`${label} contains forbidden operator-directive language: ${pattern}`);
    }
  }
}

export function validateOperatorGuidance(
  guidance: OperatorGuidance,
): OperatorGuidanceSafetyCheck {
  const violations: string[] = [];

  if (!guidance.id || guidance.id.trim().length === 0) {
    violations.push("guidance.id must be non-empty.");
  }

  if (!ALLOWED_GUIDANCE_TYPES.has(guidance.type)) {
    violations.push(`guidance.type is invalid: ${guidance.type}`);
  }

  if (!ALLOWED_GUIDANCE_DOMAINS.has(guidance.domain)) {
    violations.push(`guidance.domain is invalid: ${guidance.domain}`);
  }

  if (!ALLOWED_GUIDANCE_SEVERITIES.has(guidance.severity)) {
    violations.push(`guidance.severity is invalid: ${guidance.severity}`);
  }

  if (!ALLOWED_GUIDANCE_CONFIDENCE.has(guidance.confidence)) {
    violations.push(`guidance.confidence is invalid: ${guidance.confidence}`);
  }

  if (guidance.bounded !== true) {
    violations.push("guidance.bounded must remain true.");
  }

  if (guidance.executionImpact !== "none") {
    violations.push("guidance.executionImpact must remain 'none'.");
  }

  if (!Array.isArray(guidance.signalSource) || guidance.signalSource.length === 0) {
    violations.push("guidance.signalSource must contain at least one source.");
  }

  if (!isFiniteTimestamp(guidance.createdAt)) {
    violations.push("guidance.createdAt must be a finite non-negative timestamp.");
  }

  assertSafeText("guidance.message", guidance.message, violations);
  assertSafeText("guidance.rationale", guidance.rationale, violations);

  return {
    ok: violations.length === 0,
    violations,
  };
}

export function validateOperatorGuidanceEnvelope(
  envelope: OperatorGuidanceEnvelope,
): OperatorGuidanceSafetyCheck {
  const violations: string[] = [];

  if (envelope.executionAuthority !== "none") {
    violations.push("envelope.executionAuthority must remain 'none'.");
  }

  if (envelope.cognitionVersion !== "phase_89") {
    violations.push("envelope.cognitionVersion must remain 'phase_89'.");
  }

  if (!isFiniteTimestamp(envelope.generatedAt)) {
    violations.push("envelope.generatedAt must be a finite non-negative timestamp.");
  }

  if (!Array.isArray(envelope.guidance)) {
    violations.push("envelope.guidance must be an array.");
  } else {
    envelope.guidance.forEach((guidance, index) => {
      const result = validateOperatorGuidance(guidance);
      for (const violation of result.violations) {
        violations.push(`envelope.guidance[${index}]: ${violation}`);
      }
    });
  }

  return {
    ok: violations.length === 0,
    violations,
  };
}

export function validateOperatorGuidanceReduction(
  reduction: OperatorGuidanceReduction,
): OperatorGuidanceSafetyCheck {
  const violations: string[] = [];

  const envelopeCheck = validateOperatorGuidanceEnvelope(reduction.envelope);
  violations.push(...envelopeCheck.violations);

  if (!ALLOWED_GUIDANCE_CONFIDENCE.has(reduction.surfaceConfidence)) {
    violations.push(`reduction.surfaceConfidence is invalid: ${reduction.surfaceConfidence}`);
  }

  if (!Number.isInteger(reduction.signalCount) || reduction.signalCount < 0) {
    violations.push("reduction.signalCount must be a non-negative integer.");
  }

  if (typeof reduction.conflictingSignals !== "boolean") {
    violations.push("reduction.conflictingSignals must be boolean.");
  }

  assertSafeText("reduction.confidenceReason", reduction.confidenceReason, violations);

  return {
    ok: violations.length === 0,
    violations,
  };
}

export function assertOperatorGuidanceReductionSafe(
  reduction: OperatorGuidanceReduction,
): void {
  const result = validateOperatorGuidanceReduction(reduction);

  if (!result.ok) {
    throw new Error(
      [
        "Operator guidance safety proof failed.",
        ...result.violations.map((violation) => `- ${violation}`),
      ].join("\n"),
    );
  }
}
