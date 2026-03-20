import type { SituationFrame }
from "../situation/situationFrame.types.ts";

import type { GuidanceOutput }
from "../guidance/guidanceOutput.types.ts";

import { deriveOperatorSurface }
from "./deriveOperatorSurface.ts";

import { deriveOperatorAttention }
from "./deriveOperatorAttention.ts";

import { createOperatorAcknowledgement }
from "./deriveOperatorAcknowledgement.ts";

import { deriveOperatorWorkflowState }
from "./deriveOperatorWorkflow.ts";

import { composeOperatorInteractionOutput }
from "./composeOperatorInteractionOutput.ts";

export function deriveOperatorCognition(
  situation:SituationFrame,
  guidance:GuidanceOutput
){

  const surface =
    deriveOperatorSurface(
      situation,
      guidance
    );

  const attention =
    deriveOperatorAttention(
      surface.priority
    );

  const acknowledgement =
    createOperatorAcknowledgement(
      surface
    );

  const workflow =
    deriveOperatorWorkflowState(
      surface,
      attention,
      acknowledgement
    );

  return composeOperatorInteractionOutput({

    surface,

    attention,

    acknowledgement,

    workflow,

    history:[]

  });

}
