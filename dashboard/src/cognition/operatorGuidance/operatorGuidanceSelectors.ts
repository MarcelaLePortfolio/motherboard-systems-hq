import type {
  OperatorGuidanceConfidence,
  OperatorGuidanceReduction,
  OperatorGuidanceRenderModel,
  OperatorGuidanceStreamEvent,
} from "./operatorGuidance";
import type { OperatorGuidanceState } from "./operatorGuidanceReducer";
import { buildOperatorGuidanceRenderModel } from "./operatorGuidanceRenderContract";

export function selectOperatorGuidanceReduction(
  state: OperatorGuidanceState,
): OperatorGuidanceReduction {
  return state.reduction;
}

export function selectOperatorGuidanceStreamEvent(
  state: OperatorGuidanceState,
): OperatorGuidanceStreamEvent {
  return state.lastEvent;
}

export function selectOperatorGuidanceRenderModel(
  state: OperatorGuidanceState,
): OperatorGuidanceRenderModel {
  return buildOperatorGuidanceRenderModel(state.lastEvent);
}

export function selectOperatorGuidanceConfidence(
  state: OperatorGuidanceState,
): OperatorGuidanceConfidence {
  return state.reduction.surfaceConfidence;
}

export function selectOperatorGuidanceSources(
  state: OperatorGuidanceState,
): string[] {
  const deduped = new Set<string>();

  for (const guidance of state.reduction.envelope.guidance) {
    for (const source of guidance.signalSource) {
      deduped.add(source);
    }
  }

  return [...deduped];
}
