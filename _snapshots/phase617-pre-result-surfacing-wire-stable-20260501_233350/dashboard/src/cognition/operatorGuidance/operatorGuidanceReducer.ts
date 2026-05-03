import type {
  OperatorGuidanceReduction,
  OperatorGuidanceStreamEvent,
} from "./operatorGuidance";
import {
  EMPTY_OPERATOR_GUIDANCE_REDUCTION,
  EMPTY_OPERATOR_GUIDANCE_STREAM_EVENT,
} from "./operatorGuidance";
import {
  normalizeOperatorGuidanceReduction,
  normalizeOperatorGuidanceStreamEvent,
} from "./operatorGuidanceRenderContract";

export interface OperatorGuidanceState {
  reduction: OperatorGuidanceReduction;
  lastEvent: OperatorGuidanceStreamEvent;
}

export type OperatorGuidanceAction =
  | {
      type: "operatorGuidance/replace";
      payload: OperatorGuidanceReduction;
    }
  | {
      type: "operatorGuidance/streamEvent";
      payload: OperatorGuidanceStreamEvent;
    }
  | {
      type: "operatorGuidance/reset";
    };

export const INITIAL_OPERATOR_GUIDANCE_STATE: OperatorGuidanceState = {
  reduction: EMPTY_OPERATOR_GUIDANCE_REDUCTION,
  lastEvent: EMPTY_OPERATOR_GUIDANCE_STREAM_EVENT,
};

export function operatorGuidanceReducer(
  state: OperatorGuidanceState = INITIAL_OPERATOR_GUIDANCE_STATE,
  action: OperatorGuidanceAction,
): OperatorGuidanceState {
  switch (action.type) {
    case "operatorGuidance/replace": {
      const reduction = normalizeOperatorGuidanceReduction(action.payload);
      return {
        ...state,
        reduction,
        lastEvent: {
          reduction,
          source: state.lastEvent.source,
          ts: state.lastEvent.ts,
        },
      };
    }

    case "operatorGuidance/streamEvent": {
      const lastEvent = normalizeOperatorGuidanceStreamEvent(action.payload);
      return {
        reduction: lastEvent.reduction,
        lastEvent,
      };
    }

    case "operatorGuidance/reset":
      return INITIAL_OPERATOR_GUIDANCE_STATE;

    default:
      return state;
  }
}

export function replaceOperatorGuidance(
  payload: OperatorGuidanceReduction,
): OperatorGuidanceAction {
  return {
    type: "operatorGuidance/replace",
    payload,
  };
}

export function applyOperatorGuidanceStreamEvent(
  payload: OperatorGuidanceStreamEvent,
): OperatorGuidanceAction {
  return {
    type: "operatorGuidance/streamEvent",
    payload,
  };
}

export function resetOperatorGuidance(): OperatorGuidanceAction {
  return {
    type: "operatorGuidance/reset",
  };
}
