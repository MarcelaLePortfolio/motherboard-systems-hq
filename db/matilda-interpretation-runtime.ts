
import Database from "better-sqlite3";

const sqlite = new Database("db/main.db");

sqlite.pragma("foreign_keys = ON");

export type CreateInterpretationEvidenceLedgerEntryInput = {

  entry_id: string;

  actor: string;

  project_id?: string | null;

  conversation_id?: string | null;

  interpretation_event: string;

  minimum_sufficient_context: string;

  supporting_raw_evidence: string;

  matilda_observation: string;

  unresolved_questions?: string | null;

  lineage_references?: string | null;

  supersession_status?: string | null;
  investigation_lifecycle_json?: string | null;

};

export type CreatedInterpretationEvidenceLedgerEntry = {

  entry_id: string;

  project_id: string | null;

  conversation_id: string | null;

  created_at: string;

};

const requiredTextFields = [

  "entry_id",

  "actor",

  "interpretation_event",

  "minimum_sufficient_context",

  "supporting_raw_evidence",

  "matilda_observation",

] as const;

function ensureInterpretationEvidenceLedgerTable() {

  sqlite.exec(`

    CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger (

      entry_id TEXT PRIMARY KEY,

      created_at TEXT NOT NULL,

      actor TEXT NOT NULL,

      project_id TEXT,

      conversation_id TEXT,

      interpretation_event TEXT NOT NULL,

      minimum_sufficient_context TEXT NOT NULL,

      supporting_raw_evidence TEXT NOT NULL,

      matilda_observation TEXT NOT NULL,

      unresolved_questions TEXT,

      lineage_references TEXT,

      investigation_lifecycle_json TEXT,
      supersession_status TEXT NOT NULL DEFAULT 'current'

    );

  `);


  const columns = sqlite
    .prepare("PRAGMA table_info(matilda_interpretation_evidence_ledger)")
    .all() as Array<{ name: string }>;

  if (!columns.some((column) => column.name === "project_id")) {
    sqlite.exec(`
      ALTER TABLE matilda_interpretation_evidence_ledger
      ADD COLUMN project_id TEXT;
    `);
  }

  if (!columns.some((column) => column.name === "conversation_id")) {
    sqlite.exec(`
      ALTER TABLE matilda_interpretation_evidence_ledger
      ADD COLUMN conversation_id TEXT;
    `);
  }

  const conversationTurnsTable = sqlite
    .prepare(`
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name = 'matilda_conversation_turns'
      LIMIT 1
    `)
    .get();

  if (conversationTurnsTable) {
    sqlite.exec(`
      UPDATE matilda_interpretation_evidence_ledger
      SET
        project_id = (
          SELECT turns.project_id
          FROM matilda_conversation_turns AS turns
          WHERE turns.interpretation_entry_id =
            matilda_interpretation_evidence_ledger.entry_id
          LIMIT 1
        ),
        conversation_id = (
          SELECT turns.conversation_id
          FROM matilda_conversation_turns AS turns
          WHERE turns.interpretation_entry_id =
            matilda_interpretation_evidence_ledger.entry_id
          LIMIT 1
        )
      WHERE EXISTS (
        SELECT 1
        FROM matilda_conversation_turns AS turns
        WHERE turns.interpretation_entry_id =
          matilda_interpretation_evidence_ledger.entry_id
      )
        AND (
          project_id IS NULL
          OR TRIM(project_id) = ''
          OR conversation_id IS NULL
          OR TRIM(conversation_id) = ''
        );
    `);
  }

  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_iel_conversation_created
    ON matilda_interpretation_evidence_ledger (
      conversation_id,
      created_at
    );
  `);

  const lifecycleColumns = sqlite
    .prepare(
      "PRAGMA table_info(matilda_interpretation_evidence_ledger)",
    )
    .all() as Array<{ name: string }>;

  if (
    !lifecycleColumns.some(
      (column) => column.name === "investigation_lifecycle_json",
    )
  ) {
    sqlite.exec(`
      ALTER TABLE matilda_interpretation_evidence_ledger
      ADD COLUMN investigation_lifecycle_json TEXT;
    `);
  }
}

function requireText(

  input: CreateInterpretationEvidenceLedgerEntryInput,

  field: (typeof requiredTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required Matilda IEL field: ${field}`);

  }

  return value.trim();

}

function optionalText(value: string | null | undefined): string | null {

  if (value === undefined || value === null) return null;

  return String(value);
}

export function createInterpretationEvidenceLedgerEntry(

  input: CreateInterpretationEvidenceLedgerEntryInput,

): CreatedInterpretationEvidenceLedgerEntry {

  ensureInterpretationEvidenceLedgerTable();

  const entry_id = requireText(input, "entry_id");

  const actor = requireText(input, "actor");

  const interpretation_event = requireText(input, "interpretation_event");

  const minimum_sufficient_context = requireText(input, "minimum_sufficient_context");

  const supporting_raw_evidence = requireText(input, "supporting_raw_evidence");

  const matilda_observation = requireText(input, "matilda_observation");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO matilda_interpretation_evidence_ledger (

      entry_id,

      created_at,

      actor,

      project_id,

      conversation_id,

      interpretation_event,

      minimum_sufficient_context,

      supporting_raw_evidence,

      matilda_observation,

      unresolved_questions,

      lineage_references,

      investigation_lifecycle_json,
      supersession_status

    ) VALUES (

      @entry_id,

      @created_at,

      @actor,

      @project_id,

      @conversation_id,

      @interpretation_event,

      @minimum_sufficient_context,

      @supporting_raw_evidence,

      @matilda_observation,

      @unresolved_questions,

      @lineage_references,

      @investigation_lifecycle_json,
      @supersession_status

    )

  `).run({

    entry_id,

    created_at,

    actor,

    project_id: optionalText(input.project_id),

    conversation_id: optionalText(input.conversation_id),

    interpretation_event,

    minimum_sufficient_context,

    supporting_raw_evidence,

    matilda_observation,

    unresolved_questions: optionalText(input.unresolved_questions),

    lineage_references: optionalText(input.lineage_references),

    investigation_lifecycle_json:
      input.investigation_lifecycle_json ?? null,
    supersession_status: optionalText(input.supersession_status) || "current",

  });

  return {

    entry_id,

    project_id: optionalText(input.project_id),

    conversation_id: optionalText(input.conversation_id),

    created_at,

  };

}

export function listInterpretationEvidenceLedgerEntries(limit = 20) {

  ensureInterpretationEvidenceLedgerTable();

  return sqlite.prepare(`

    SELECT

      entry_id,

      created_at,

      actor,

      project_id,

      conversation_id,

      interpretation_event,

      minimum_sufficient_context,

      supporting_raw_evidence,

      matilda_observation,

      unresolved_questions,

      lineage_references,

      supersession_status

    FROM matilda_interpretation_evidence_ledger

    ORDER BY created_at DESC

    LIMIT ?

  `).all(Math.max(1, Math.min(Number(limit) || 20, 100)));

}

