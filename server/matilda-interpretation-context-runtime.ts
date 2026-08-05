import type {
  MatildaConversationHistoryContextTurn,
} from "./matilda-conversation-history-context";

export interface MatildaInterpretationLifecycleEntry {
  entry_id: string;
  supersession_status: string;
}

export type MatildaInterpretationSupersessionStatus =
  | "current"
  | "superseded"
  | "unknown";

export interface MatildaInterpretationContext {
  interpretationEntryId: string;
  sourceTurnId: string;
  supersessionStatus:
    MatildaInterpretationSupersessionStatus;
  contaminationStatus:
    MatildaConversationHistoryContextTurn["contaminationStatus"];
}

function resolveSupersessionStatus(
  value: string | null | undefined,
): MatildaInterpretationSupersessionStatus {
  const normalized =
    String(value ?? "")
      .trim()
      .toLowerCase();

  switch (normalized) {
    case "current":
      return "current";

    case "superseded":
      return "superseded";

    default:
      return "unknown";
  }
}

export function buildInterpretationContext(
  history:
    MatildaConversationHistoryContextTurn[],
  lifecycleEntries:
    MatildaInterpretationLifecycleEntry[] = [],
): MatildaInterpretationContext[] {
  const lifecycleByEntryId =
    new Map(
      lifecycleEntries.map((entry) => [
        entry.entry_id,
        entry.supersession_status,
      ]),
    );

  return history.map((turn) => ({
    interpretationEntryId:
      turn.interpretationEntryId,
    sourceTurnId:
      turn.sourceTurnId,
    supersessionStatus:
      resolveSupersessionStatus(
        lifecycleByEntryId.get(
          turn.interpretationEntryId,
        ),
      ),
    contaminationStatus:
      turn.contaminationStatus,
  }));
}
