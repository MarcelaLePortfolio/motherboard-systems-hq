import type { GuidanceOutput } from "../guidance/guidanceOutput.types.ts";
import { toGoldenGuidanceOutput } from "../guidance/goldenGuidanceOutput.ts";
import type { SituationFrame } from "../situation/situationFrame.types.ts";
import { createOperatorAcknowledgement } from "./deriveOperatorAcknowledgement.ts";
import { deriveOperatorAttention } from "./deriveOperatorAttention.ts";
import { composeOperatorInteractionOutput } from "./composeOperatorInteractionOutput.ts";
import { deriveOperatorSurface } from "./deriveOperatorSurface.ts";
import { deriveOperatorWorkflowState } from "./deriveOperatorWorkflow.ts";

export function deriveOperatorCognition(
  situation: SituationFrame,
  guidance: GuidanceOutput
) {
  const goldenGuidance = toGoldenGuidanceOutput(guidance);

  const baseSurface = deriveOperatorSurface(goldenGuidance);

  const surface = {
    ...baseSurface,
    title: situation.title,
    explanation: situation.summary,
  };

  const attention = deriveOperatorAttention(surface.priority);

  const acknowledgement =
    createOperatorAcknowledgement(surface);

  const workflow = deriveOperatorWorkflowState(
    surface,
    attention,
    acknowledgement
  );

  return composeOperatorInteractionOutput({
    surface,
    attention,
    acknowledgement,
    workflow,
    history: [],
  });
}
