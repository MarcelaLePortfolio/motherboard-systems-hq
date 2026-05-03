import { OperatorInteractionOutput } from "../types/OperatorInteractionOutput.ts";

export interface OperatorCognitionState {
  current: OperatorInteractionOutput | null;
}

export const initialOperatorCognitionState: OperatorCognitionState = {
  current: null,
};

export function operatorCognitionReducer(
  state: OperatorCognitionState,
  cognition: OperatorInteractionOutput
): OperatorCognitionState {
  return {
    current: cognition,
  };
}
