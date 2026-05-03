import type { OperatorSurface } from "./operatorSurface.types.ts";
import type { OperatorAttention } from "./operatorAttention.types.ts";
import type { OperatorAcknowledgement } from "./operatorAcknowledgement.types.ts";

export interface OperatorWorkflowState {

  surface:OperatorSurface;

  attention:OperatorAttention;

  acknowledgement:OperatorAcknowledgement;

  requiresAction:boolean;

  readyForAutomation:boolean;

}

