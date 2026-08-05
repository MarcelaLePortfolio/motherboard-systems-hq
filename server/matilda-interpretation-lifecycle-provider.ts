import type {
  MatildaInterpretationLifecycleEntry,
} from "./matilda-interpretation-context-runtime";

export interface MatildaInterpretationLedgerEntry {
  entry_id: string;
  supersession_status: string;
}

export function selectMatildaInterpretationLifecycleEntries(
  interpretationEntryIds: string[],
  ledgerEntries: MatildaInterpretationLedgerEntry[],
): MatildaInterpretationLifecycleEntry[] {
  const requestedIds = new Set(
    interpretationEntryIds
      .map((id) => id.trim())
      .filter(Boolean),
  );

  return ledgerEntries
    .filter((entry) =>
      requestedIds.has(entry.entry_id),
    )
    .map((entry) => ({
      entry_id: entry.entry_id,
      supersession_status:
        entry.supersession_status,
    }));
}
