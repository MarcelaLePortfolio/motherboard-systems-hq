
import Database from "better-sqlite3";

const sqlite = new Database("db/main.db");

sqlite.pragma("foreign_keys = ON");

export type CreateInterpretationEvidenceLedgerEntryInput = {

  entry_id: string;

  actor: string;

  interpretation_event: string;

  minimum_sufficient_context: string;

  supporting_raw_evidence: string;

  matilda_observation: string;

  unresolved_questions?: string | null;

  lineage_references?: string | null;

  supersession_status?: string | null;

};

export type CreatedInterpretationEvidenceLedgerEntry = {

  entry_id: string;

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

      interpretation_event TEXT NOT NULL,

      minimum_sufficient_context TEXT NOT NULL,

      supporting_raw_evidence TEXT NOT NULL,

      matilda_observation TEXT NOT NULL,

      unresolved_questions TEXT,

      lineage_references TEXT,

      supersession_status TEXT NOT NULL DEFAULT 'current'

    );

  `);

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

      interpretation_event,

      minimum_sufficient_context,

      supporting_raw_evidence,

      matilda_observation,

      unresolved_questions,

      lineage_references,

      supersession_status

    ) VALUES (

      @entry_id,

      @created_at,

      @actor,

      @interpretation_event,

      @minimum_sufficient_context,

      @supporting_raw_evidence,

      @matilda_observation,

      @unresolved_questions,

      @lineage_references,

      @supersession_status

    )

  `).run({

    entry_id,

    created_at,

    actor,

    interpretation_event,

    minimum_sufficient_context,

    supporting_raw_evidence,

    matilda_observation,

    unresolved_questions: optionalText(input.unresolved_questions),

    lineage_references: optionalText(input.lineage_references),

    supersession_status: optionalText(input.supersession_status) || "current",

  });

  return {

    entry_id,

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

