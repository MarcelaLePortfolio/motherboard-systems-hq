import {
  EMPTY_OPERATOR_GUIDANCE_ENVELOPE,
  type OperatorGuidanceEnvelope,
} from "./operatorGuidance";

export interface OperatorGuidanceState {
  envelope: OperatorGuidanceEnvelope;
}

export type OperatorGuidanceAction =
  | {
      type: "operatorGuidance/replace";
      payload: OperatorGuidanceEnvelope;
    }
  | {
      type: "operatorGuidance/reset";
    };

export const INITIAL_OPERATOR_GUIDANCE_STATE: OperatorGuidanceState = {
  envelope: EMPTY_OPERATOR_GUIDANCE_ENVELOPE,
};

export function operatorGuidanceReducer(
  state: OperatorGuidanceState = INITIAL_OPERATOR_GUIDANCE_STATE,
  action: OperatorGuidanceAction,
): OperatorGuidanceState {
  switch (action.type) {
    case "operatorGuidance/replace":
      return {
        ...state,
        envelope: action.payload,
      };

    case "operatorGuidance/reset":
      return INITIAL_OPERATOR_GUIDANCE_STATE;

    default:
      return state;
  }
}
