import type {
  OperatorHistory,
  OperatorHistoryEntry,
} from "./operatorHistory.types.ts";
import type { OperatorAcknowledgement } from "./operatorAcknowledgement.types.ts";
import type { OperatorAttention } from "./operatorAttention.types.ts";
import type { OperatorSurface } from "./operatorSurface.types.ts";

function compareEntries(
  a: OperatorHistoryEntry,
  b: OperatorHistoryEntry
): number {
  if (a.recordedAt !== b.recordedAt) {
    return a.recordedAt - b.recordedAt;
  }

  return a.surface.id.localeCompare(b.surface.id);
}

export function createOperatorHistory(): OperatorHistory {
  return {
    entries: [],
  };
}

export function appendOperatorHistoryEntry(
  history: OperatorHistory,
  args: {
    surface: OperatorSurface;
    attention: OperatorAttention;
    acknowledgement: OperatorAcknowledgement;
    recordedAt: number;
  }
): OperatorHistory {
  const nextEntries = [
    ...history.entries,
    {
      surface: args.surface,
      attention: args.attention,
      acknowledgement: args.acknowledgement,
      recordedAt: args.recordedAt,
    },
  ].sort(compareEntries);

  return {
    entries: nextEntries,
  };
}
