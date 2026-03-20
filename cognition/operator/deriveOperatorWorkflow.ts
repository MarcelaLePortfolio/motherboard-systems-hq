import type { OperatorWorkflowState }
from "./operatorWorkflow.types.ts";

import type { OperatorSurface }
from "./operatorSurface.types.ts";

import type { OperatorAttention }
from "./operatorAttention.types.ts";

import type { OperatorAcknowledgement }
from "./operatorAcknowledgement.types.ts";

export function deriveOperatorWorkflowState(
  surface:OperatorSurface,
  attention:OperatorAttention,
  acknowledgement:OperatorAcknowledgement
):OperatorWorkflowState{

  const requiresAction =
    surface.requiresHumanConfirmation &&
    !acknowledgement.acknowledged;

  const readyForAutomation =
    surface.allowAutomation &&
    acknowledgement.acknowledged;

  return{

    surface,

    attention,

    acknowledgement,

    requiresAction,

    readyForAutomation

  };

}
