/*
PHASE 89 — BOUNDED OPERATOR GUIDANCE LAYER
Guidance Schema (Authoritative Type Contracts)

Rules:
- Cognition only (no execution authority)
- Deterministic interpretation only
- Bounded messaging
- Confidence must be explicit
- No repair instructions
*/

export type GuidanceConfidence =
  | "high"
  | "medium"
  | "low"
  | "insufficient";

export type GuidanceSeverity =
  | "info"
  | "attention"
  | "elevated"
  | "critical";

export type GuidanceDomain =
  | "system_health"
  | "throughput"
  | "latency"
  | "task_lifecycle"
  | "signal_quality"
  | "operator_awareness";

export type OperatorGuidanceBase = {
  id: string;

  domain: GuidanceDomain;

  severity: GuidanceSeverity;

  confidence: GuidanceConfidence;

  message: string;

  rationale: string;

  signalSource: string[];

  bounded: true;

  executionImpact: "none";

  createdAt: number;
};

export type InformationalGuidance = OperatorGuidanceBase & {
  type: "informational";
};

export type AttentionGuidance = OperatorGuidanceBase & {
  type: "attention";
};

export type ElevatedGuidance = OperatorGuidanceBase & {
  type: "elevated";
};

export type CriticalGuidance = OperatorGuidanceBase & {
  type: "critical";
};

export type OperatorGuidance =
  | InformationalGuidance
  | AttentionGuidance
  | ElevatedGuidance
  | CriticalGuidance;

/*
Deterministic envelope for reducer output.
Prevents unsafe structure drift.
*/

export type OperatorGuidanceEnvelope = {
  guidance: OperatorGuidance[];

  generatedAt: number;

  cognitionVersion: "phase_89";

  executionAuthority: "none";
};

/*
Safety invariants (type-level guarantees):

- No execution authority exposed
- No automation triggers
- No repair actions
- Guidance is observational only
*/

export const GUIDANCE_EXECUTION_AUTHORITY = "none" as const;

export const GUIDANCE_BOUNDED_FLAG = true as const;
