/**
 * Phase 101.2 — Deterministic Selectors
 *
 * Purpose:
 * Provide pure, read-only selectors over cognition contract envelopes.
 *
 * Rules:
 * - Read-only access
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 * - Deterministic outputs only
 */

import type {
  CognitionContractEnvelope,
  GovernanceCognitionContract,
  OperatorGuidanceContract,
  SituationSummaryContract
} from "../contracts/cognition.contracts";

export function selectSituationSummary(
  envelope: CognitionContractEnvelope
): SituationSummaryContract | null {
  return envelope.situation ?? null;
}

export function selectOperatorGuidance(
  envelope: CognitionContractEnvelope
): OperatorGuidanceContract[] {
  return envelope.guidance ?? [];
}

export function selectGovernanceCognition(
  envelope: CognitionContractEnvelope
): GovernanceCognitionContract[] {
  return envelope.governance ?? [];
}

export function selectHasSituationSummary(
  envelope: CognitionContractEnvelope
): boolean {
  return envelope.situation != null;
}

export function selectHasOperatorGuidance(
  envelope: CognitionContractEnvelope
): boolean {
  return Array.isArray(envelope.guidance) && envelope.guidance.length > 0;
}

export function selectHasGovernanceCognition(
  envelope: CognitionContractEnvelope
): boolean {
  return Array.isArray(envelope.governance) && envelope.governance.length > 0;
}

export function selectCognitionEnvelopePresence(
  envelope: CognitionContractEnvelope
): {
  hasSituation: boolean;
  hasGuidance: boolean;
  hasGovernance: boolean;
} {
  return {
    hasSituation: selectHasSituationSummary(envelope),
    hasGuidance: selectHasOperatorGuidance(envelope),
    hasGovernance: selectHasGovernanceCognition(envelope)
  };
}
