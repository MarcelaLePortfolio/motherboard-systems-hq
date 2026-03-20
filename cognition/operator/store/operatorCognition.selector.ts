import { OperatorCognitionState } from "./operatorCognition.reducer.ts";

export function selectOperatorCognition(
  state: OperatorCognitionState
) {
  return state.current;
}
