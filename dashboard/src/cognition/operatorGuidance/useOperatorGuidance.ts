import { useMemo, useReducer } from "react";

import type { OperatorGuidanceEnvelope } from "./operatorGuidance";
import {
  INITIAL_OPERATOR_GUIDANCE_STATE,
  operatorGuidanceReducer,
  replaceOperatorGuidance,
  resetOperatorGuidance,
} from "./operatorGuidanceReducer";

export interface UseOperatorGuidanceResult {
  envelope: OperatorGuidanceEnvelope;
  replaceEnvelope: (nextEnvelope: OperatorGuidanceEnvelope) => void;
  resetEnvelope: () => void;
}

export function useOperatorGuidance(): UseOperatorGuidanceResult {
  const [state, dispatch] = useReducer(
    operatorGuidanceReducer,
    INITIAL_OPERATOR_GUIDANCE_STATE,
  );

  return useMemo(
    () => ({
      envelope: state.envelope,
      replaceEnvelope: (nextEnvelope: OperatorGuidanceEnvelope) => {
        dispatch(replaceOperatorGuidance(nextEnvelope));
      },
      resetEnvelope: () => {
        dispatch(resetOperatorGuidance());
      },
    }),
    [state.envelope],
  );
}
