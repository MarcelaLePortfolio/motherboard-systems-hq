import { useMemo, useReducer } from "react";

import type {
  OperatorGuidanceReduction,
  OperatorGuidanceRenderModel,
  OperatorGuidanceStreamEvent,
} from "./operatorGuidance";
import {
  INITIAL_OPERATOR_GUIDANCE_STATE,
  applyOperatorGuidanceStreamEvent,
  operatorGuidanceReducer,
  replaceOperatorGuidance,
  resetOperatorGuidance,
} from "./operatorGuidanceReducer";
import { buildOperatorGuidanceRenderModel } from "./operatorGuidanceRenderContract";

export interface UseOperatorGuidanceResult {
  reduction: OperatorGuidanceReduction;
  renderModel: OperatorGuidanceRenderModel;
  replaceReduction: (nextReduction: OperatorGuidanceReduction) => void;
  applyStreamEvent: (nextEvent: OperatorGuidanceStreamEvent) => void;
  reset: () => void;
}

export function useOperatorGuidance(): UseOperatorGuidanceResult {
  const [state, dispatch] = useReducer(
    operatorGuidanceReducer,
    INITIAL_OPERATOR_GUIDANCE_STATE,
  );

  return useMemo(
    () => ({
      reduction: state.reduction,
      renderModel: buildOperatorGuidanceRenderModel(state.lastEvent),
      replaceReduction: (nextReduction: OperatorGuidanceReduction) => {
        dispatch(replaceOperatorGuidance(nextReduction));
      },
      applyStreamEvent: (nextEvent: OperatorGuidanceStreamEvent) => {
        dispatch(applyOperatorGuidanceStreamEvent(nextEvent));
      },
      reset: () => {
        dispatch(resetOperatorGuidance());
      },
    }),
    [state.lastEvent, state.reduction],
  );
}
