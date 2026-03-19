import type { OperatorGuidanceEnvelope } from "./operatorGuidance";
import type { OperatorGuidanceState } from "./operatorGuidanceReducer";

export function selectOperatorGuidanceEnvelope(
  state: OperatorGuidanceState,
): OperatorGuidanceEnvelope {
  return state.envelope;
}

export function selectOperatorGuidanceConfidence(
  state: OperatorGuidanceState,
): OperatorGuidanceEnvelope["confidence"] {
  return state.envelope.confidence;
}

export function selectOperatorGuidanceSources(
  state: OperatorGuidanceState,
): string[] {
  return state.envelope.sources;
}
