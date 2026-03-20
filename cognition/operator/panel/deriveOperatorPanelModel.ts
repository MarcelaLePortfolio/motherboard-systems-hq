import { OperatorInteractionOutput } from "../types/OperatorInteractionOutput.ts";

export interface OperatorPanelModel {
  title: string;
  explanation: string;
  priority: string;
  requiresAttention: boolean;
  requiresAcknowledgement: boolean;
}

export function deriveOperatorPanelModel(
  cognition: OperatorInteractionOutput | null
): OperatorPanelModel | null {

  if (!cognition) {
    return null;
  }

  return {
    title: cognition.surface.title,
    explanation: cognition.surface.explanation,
    priority: cognition.surface.priority,
    requiresAttention: cognition.attention.requiresAttention,
    requiresAcknowledgement:
      cognition.workflow.requiresAcknowledgement,
  };
}
