import type {
  MatildaSelectedHistoryTurn,
} from "./matilda-history-selection-runtime";
import {
  readMatildaPersistedSupportProvenance,
  type MatildaPersistedSupportProvenance,
} from "./matilda-support-provenance";

export interface MatildaSupportProvenanceLedgerEntry {
  entry_id: string;
  supporting_raw_evidence: string;
}

export type MatildaPriorSupportProvenanceStatus =
  | "sufficient"
  | "insufficient"
  | "unavailable";

export interface MatildaPriorSupportProvenanceResult {
  status: MatildaPriorSupportProvenanceStatus;
  provenance: MatildaPersistedSupportProvenance | null;
}

export function recoverMatildaPriorSupportProvenance(
  selectedHistory: MatildaSelectedHistoryTurn[],
  ledgerEntries: MatildaSupportProvenanceLedgerEntry[],
): MatildaPriorSupportProvenanceResult {
  const priorTurn =
    selectedHistory.length > 0
      ? selectedHistory[selectedHistory.length - 1]
      : null;

  if (!priorTurn) {
    return {
      status: "unavailable",
      provenance: null,
    };
  }

  const ledgerEntry =
    ledgerEntries.find(
      (entry) =>
        entry.entry_id ===
        priorTurn.interpretationEntryId,
    );

  if (!ledgerEntry) {
    return {
      status: "unavailable",
      provenance: null,
    };
  }

  const provenance =
    readMatildaPersistedSupportProvenance(
      ledgerEntry.supporting_raw_evidence,
    );

  if (!provenance) {
    return {
      status: "unavailable",
      provenance: null,
    };
  }

  return {
    status: provenance.evidenceSufficient
      ? "sufficient"
      : "insufficient",
    provenance,
  };
}
