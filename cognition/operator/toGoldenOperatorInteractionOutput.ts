import type { OperatorInteractionOutput }
from "./operatorInteractionOutput.types.ts";

export interface GoldenOperatorInteractionOutput{

  id:string;

  priority:string;

  title:string;

  explanation:string;

  action:string;

  attention:string;

  requiresAction:boolean;

  readyForAutomation:boolean;

  acknowledged:boolean;

}

export function toGoldenOperatorInteractionOutput(
  input:OperatorInteractionOutput
):GoldenOperatorInteractionOutput{

  return{

    id:input.surface.id,

    priority:String(input.surface.priority),

    title:input.surface.title,

    explanation:input.surface.explanation,

    action:input.surface.actionMessage,

    attention:input.attention.badge,

    requiresAction:input.workflow.requiresAction,

    readyForAutomation:input.workflow.readyForAutomation,

    acknowledged:input.acknowledgement.acknowledged

  };

}
