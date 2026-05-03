import type { OperatorAcknowledgement } from "./operatorAcknowledgement.types.ts";
import type { OperatorAttention } from "./operatorAttention.types.ts";
import type { OperatorSurface } from "./operatorSurface.types.ts";

export interface OperatorHistoryEntry {
  surface: OperatorSurface;
  attention: OperatorAttention;
  acknowledgement: OperatorAcknowledgement;
  recordedAt: number;
}

export interface OperatorHistory {
  entries: OperatorHistoryEntry[];
}
