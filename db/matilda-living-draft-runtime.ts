
import Database from "better-sqlite3";

const sqlite = new Database("db/main.db");

sqlite.pragma("foreign_keys = ON");

export type UpsertLivingDraftPackageInput = {

  draft_package_id: string;

  lineage_id: string;

  project_id?: string | null;

  conversation_id?: string | null;

  current_interpretation: string;

  proposed_work?: string | null;

  proposed_artifacts?: string | null;

  in_scope?: string | null;

  out_of_scope?: string | null;

  constraints?: string | null;

  expected_outcome?: string | null;

  unresolved_questions?: string | null;

  evidence_entry_ids: string[];

  status?: string | null;

};

export type LivingDraftStatus =
  | "draft_non_authoritative"
  | "reconciliation_in_progress"
  | "reconciliation_ready"
  | "reconciled_interpretation_generated"
  | "canonical_package_created";

export type LivingDraftPackageRecord = UpsertLivingDraftPackageInput & {

  evidence_entry_ids: string[];

  status: LivingDraftStatus;

  created_at: string;

  updated_at: string;

};

function ensureLivingDraftPackageTable() {

  sqlite.exec(`

    CREATE TABLE IF NOT EXISTS matilda_living_draft_packages (

      draft_package_id TEXT PRIMARY KEY,

      lineage_id TEXT NOT NULL,

      project_id TEXT,

      conversation_id TEXT,

      current_interpretation TEXT NOT NULL,

      proposed_work TEXT,

      proposed_artifacts TEXT,

      in_scope TEXT,

      out_of_scope TEXT,

      constraints TEXT,

      expected_outcome TEXT,

      unresolved_questions TEXT,

      evidence_entry_ids TEXT NOT NULL,

      status TEXT NOT NULL,

      created_at TEXT NOT NULL,

      updated_at TEXT NOT NULL

    );

  `);


  const columns = sqlite
    .prepare("PRAGMA table_info(matilda_living_draft_packages)")
    .all() as Array<{ name: string }>;

  if (!columns.some((column) => column.name === "project_id")) {
    sqlite.exec(`
      ALTER TABLE matilda_living_draft_packages
      ADD COLUMN project_id TEXT;
    `);
  }

  if (!columns.some((column) => column.name === "conversation_id")) {
    sqlite.exec(`
      ALTER TABLE matilda_living_draft_packages
      ADD COLUMN conversation_id TEXT;
    `);
  }

  const requiredTables = sqlite
    .prepare(`
      SELECT COUNT(*) AS table_count
      FROM sqlite_master
      WHERE type = 'table'
        AND name IN (
          'matilda_interpretation_evidence_ledger',
          'matilda_conversation_turns'
        )
    `)
    .get() as { table_count: number };

  if (requiredTables.table_count === 2) {
    const drafts = sqlite
      .prepare(`
        SELECT draft_package_id, evidence_entry_ids
        FROM matilda_living_draft_packages
        WHERE project_id IS NULL
           OR TRIM(project_id) = ''
           OR conversation_id IS NULL
           OR TRIM(conversation_id) = ''
      `)
      .all() as Array<{
        draft_package_id: string;
        evidence_entry_ids: string;
      }>;

    const resolveOwnership = sqlite.prepare(`
      SELECT
        GROUP_CONCAT(DISTINCT turns.project_id) AS projects,
        GROUP_CONCAT(DISTINCT turns.conversation_id) AS conversations,
        COUNT(DISTINCT turns.project_id) AS project_count,
        COUNT(DISTINCT turns.conversation_id) AS conversation_count
      FROM json_each(?) AS evidence
      JOIN matilda_conversation_turns AS turns
        ON turns.interpretation_entry_id = evidence.value
    `);

    const updateOwnership = sqlite.prepare(`
      UPDATE matilda_living_draft_packages
      SET project_id = ?, conversation_id = ?
      WHERE draft_package_id = ?
    `);

    const backfill = sqlite.transaction(() => {
      for (const draft of drafts) {
        const ownership = resolveOwnership.get(
          draft.evidence_entry_ids
        ) as {
          projects: string | null;
          conversations: string | null;
          project_count: number;
          conversation_count: number;
        };

        if (
          ownership.project_count === 1
          && ownership.conversation_count === 1
          && ownership.projects
          && ownership.conversations
        ) {
          updateOwnership.run(
            ownership.projects,
            ownership.conversations,
            draft.draft_package_id
          );
        }
      }
    });

    backfill();
  }

  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_living_drafts_conversation_updated
    ON matilda_living_draft_packages (
      conversation_id,
      updated_at
    );
  `);
}

function requireText(value: unknown, field: string): string {

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required Matilda Living Draft Package field: ${field}`);

  }

  return value.trim();

}

function optionalText(value: string | null | undefined): string | null {

  if (value === undefined || value === null) return null;

  return String(value);

}

function normalizeEvidenceEntryIds(value: unknown): string[] {

  if (!Array.isArray(value)) {

    throw new Error("Missing required Matilda Living Draft Package field: evidence_entry_ids");

  }

  const normalized = value

    .map((item) => String(item || "").trim())

    .filter(Boolean);

  if (normalized.length === 0) {

    throw new Error("Living Draft Package requires at least one evidence entry id.");

  }

  return Array.from(new Set(normalized));

}

export function upsertLivingDraftPackage(

  input: UpsertLivingDraftPackageInput,

): LivingDraftPackageRecord {

  ensureLivingDraftPackageTable();

  const draft_package_id = requireText(input.draft_package_id, "draft_package_id");

  const lineage_id = requireText(input.lineage_id, "lineage_id");

  const current_interpretation = requireText(

    input.current_interpretation,

    "current_interpretation",

  );

  const evidence_entry_ids = normalizeEvidenceEntryIds(input.evidence_entry_ids);

  const status =
    (optionalText(input.status) as LivingDraftStatus | null)
      ?? "draft_non_authoritative";

  const existing = sqlite

    .prepare(

      `SELECT created_at FROM matilda_living_draft_packages WHERE draft_package_id = ?`,

    )

    .get(draft_package_id) as { created_at?: string } | undefined;

  const timestamp = new Date().toISOString();

  const created_at = existing?.created_at || timestamp;

  const updated_at = timestamp;

  sqlite.prepare(`

    INSERT INTO matilda_living_draft_packages (

      draft_package_id,

      lineage_id,

      project_id,

      conversation_id,

      current_interpretation,

      proposed_work,

      proposed_artifacts,

      in_scope,

      out_of_scope,

      constraints,

      expected_outcome,

      unresolved_questions,

      evidence_entry_ids,

      status,

      created_at,

      updated_at

    ) VALUES (

      @draft_package_id,

      @lineage_id,

      @project_id,

      @conversation_id,

      @current_interpretation,

      @proposed_work,

      @proposed_artifacts,

      @in_scope,

      @out_of_scope,

      @constraints,

      @expected_outcome,

      @unresolved_questions,

      @evidence_entry_ids,

      @status,

      @created_at,

      @updated_at

    )

    ON CONFLICT(draft_package_id) DO UPDATE SET

      lineage_id = excluded.lineage_id,

      project_id = excluded.project_id,

      conversation_id = excluded.conversation_id,

      current_interpretation = excluded.current_interpretation,

      proposed_work = excluded.proposed_work,

      proposed_artifacts = excluded.proposed_artifacts,

      in_scope = excluded.in_scope,

      out_of_scope = excluded.out_of_scope,

      constraints = excluded.constraints,

      expected_outcome = excluded.expected_outcome,

      unresolved_questions = excluded.unresolved_questions,

      evidence_entry_ids = excluded.evidence_entry_ids,

      status = excluded.status,

      updated_at = excluded.updated_at

  `).run({

    draft_package_id,

    lineage_id,

    project_id: optionalText(input.project_id),

    conversation_id: optionalText(input.conversation_id),

    current_interpretation,

    proposed_work: optionalText(input.proposed_work),

    proposed_artifacts: optionalText(input.proposed_artifacts),

    in_scope: optionalText(input.in_scope),

    out_of_scope: optionalText(input.out_of_scope),

    constraints: optionalText(input.constraints),

    expected_outcome: optionalText(input.expected_outcome),

    unresolved_questions: optionalText(input.unresolved_questions),

    evidence_entry_ids: JSON.stringify(evidence_entry_ids),

    status,

    created_at,

    updated_at,

  });

  return {

    draft_package_id,

    lineage_id,

    project_id: optionalText(input.project_id),

    conversation_id: optionalText(input.conversation_id),

    current_interpretation,

    proposed_work: optionalText(input.proposed_work),

    proposed_artifacts: optionalText(input.proposed_artifacts),

    in_scope: optionalText(input.in_scope),

    out_of_scope: optionalText(input.out_of_scope),

    constraints: optionalText(input.constraints),

    expected_outcome: optionalText(input.expected_outcome),

    unresolved_questions: optionalText(input.unresolved_questions),

    evidence_entry_ids,

    status,

    created_at,

    updated_at,

  };

}

export function listLivingDraftPackages(limit = 20) {

  ensureLivingDraftPackageTable();

  return sqlite

    .prepare(`

      SELECT

        draft_package_id,

        lineage_id,

        project_id,

        conversation_id,

        current_interpretation,

        proposed_work,

        proposed_artifacts,

        in_scope,

        out_of_scope,

        constraints,

        expected_outcome,

        unresolved_questions,

        evidence_entry_ids,

        status,

        created_at,

        updated_at

      FROM matilda_living_draft_packages

      ORDER BY updated_at DESC

      LIMIT ?

    `)

    .all(Math.max(1, Math.min(Number(limit) || 20, 100)))

    .map((record: any) => ({

      ...record,

      evidence_entry_ids: JSON.parse(record.evidence_entry_ids || "[]"),

    }));

}

