import { SituationFrame } from "../../situation/types/SituationFrame.ts";
import { GuidanceOutput } from "../../guidance/types/GuidanceOutput.ts";
import { deriveOperatorCognition } from "../deriveOperatorCognition.ts";
import {
  operatorCognitionReducer,
  OperatorCognitionState,
} from "../store/operatorCognition.reducer.ts";

export function streamOperatorCognition(
  state: OperatorCognitionState,
  situation: SituationFrame,
  guidance: GuidanceOutput
): OperatorCognitionState {

  const cognition = deriveOperatorCognition(
    situation,
    guidance
  );

  return operatorCognitionReducer(
    state,
    cognition
  );
}
