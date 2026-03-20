import type { OperatorAcknowledgement } from "./operatorAcknowledgement.types.ts";
import type { OperatorAttention } from "./operatorAttention.types.ts";
import type { OperatorHistoryEntry } from "./operatorHistory.types.ts";
import type { OperatorSurface } from "./operatorSurface.types.ts";
import type { OperatorWorkflowState } from "./operatorWorkflow.types.ts";

export interface OperatorInteractionOutput {
  surface: OperatorSurface;
  attention: OperatorAttention;
  acknowledgement: OperatorAcknowledgement;
  workflow: OperatorWorkflowState;
  history: OperatorHistoryEntry[];
}
