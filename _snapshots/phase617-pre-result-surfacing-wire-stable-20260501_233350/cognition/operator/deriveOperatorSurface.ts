import type { GoldenGuidanceOutput }
from "../guidance/goldenGuidanceOutput.ts";

import type { OperatorSurface }
from "./operatorSurface.types.ts";

function buildStableId(
  explanation:string,
  actionMessage:string
):string{

  const base =
    explanation +
    "|" +
    actionMessage;

  let hash = 0;

  for(let i=0;i<base.length;i++){

    hash =
      (hash<<5)
      - hash
      + base.charCodeAt(i);

    hash |= 0;

  }

  return "op_"+Math.abs(hash);

}

export function deriveOperatorSurface(
  guidance:GoldenGuidanceOutput
):OperatorSurface{

  return{

    id:buildStableId(
      guidance.explanation,
      guidance.actionMessage
    ),

    priority:guidance.priority,

    title:guidance.actionMessage,

    explanation:guidance.explanation,

    actionMessage:guidance.actionMessage,

    recommendedSteps:[
      ...guidance.recommendedSteps
    ],

    prohibitedSteps:[
      ...guidance.prohibitedSteps
    ],

    requiresHumanConfirmation:
      guidance.requiresHumanConfirmation,

    allowAutomation:
      guidance.allowAutomation

  };

}
