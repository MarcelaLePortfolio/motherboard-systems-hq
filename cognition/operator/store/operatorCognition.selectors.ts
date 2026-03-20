import { OperatorCognitionState } from "./operatorCognition.reducer.ts";

export function selectOperatorInteraction(
  state: OperatorCognitionState
) {
  return state.current;
}

export function selectOperatorSurface(
  state: OperatorCognitionState
) {
  return state.current?.surface ?? null;
}

export function selectOperatorAttention(
  state: OperatorCognitionState
) {
  return state.current?.attention ?? null;
}

export function selectOperatorWorkflow(
  state: OperatorCognitionState
) {
  return state.current?.workflow ?? null;
}
