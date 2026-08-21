import { randomUUID } from "node:crypto";

import Database from "better-sqlite3";

import { getLivingDraftPackageById } from "./matilda-living-draft-read-runtime";

const sqlite = new Database("db/main.db");

sqlite.pragma("foreign_keys = ON");

export type DraftRevisionRecord = {
  draft_revision_id: string;
  draft_package_id: string;
  lineage_id: string;
  project_id: string | null;
  conversation_id: string | null;
  current_interpretation: string;
  proposed_work: string | null;
  proposed_artifacts: string | null;
  in_scope: string | null;
  out_of_scope: string | null;
  constraints: string | null;
  expected_outcome: string | null;
  unresolved_questions: string | null;
  evidence_entry_ids: string[];
  source_draft_status: string;
  source_draft_updated_at: string;
  status: "approval_review_candidate";
  created_at: string;
};

export function initializeDraftRevisionSchema() {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS matilda_draft_revisions (
      draft_revision_id TEXT PRIMARY KEY,
      draft_package_id TEXT NOT NULL,
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
      source_draft_status TEXT NOT NULL,
      source_draft_updated_at TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      UNIQUE (draft_package_id, source_draft_updated_at),
      FOREIGN KEY (draft_package_id)
        REFERENCES matilda_living_draft_packages(draft_package_id)
    )
  `);

  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_draft_revisions_lineage_created
    ON matilda_draft_revisions (
      lineage_id,
      created_at
    );
  `);
}

function mapDraftRevision(row: any): DraftRevisionRecord {
  return {
    ...row,
    evidence_entry_ids: JSON.parse(row.evidence_entry_ids || "[]"),
  };
}

export function getDraftRevisionById(
  draft_revision_id: string,
): DraftRevisionRecord {
  initializeDraftRevisionSchema();

  const row = sqlite
    .prepare(`
      SELECT *
      FROM matilda_draft_revisions
      WHERE draft_revision_id = ?
      LIMIT 1
    `)
    .get(draft_revision_id);

  if (!row) {
    throw new Error(`Draft Revision not found: ${draft_revision_id}`);
  }

  return mapDraftRevision(row);
}

export function createDraftRevisionForApprovalReview({
  draft_package_id,
}: {
  draft_package_id: string;
}): DraftRevisionRecord {
  initializeDraftRevisionSchema();

  const draft = getLivingDraftPackageById(draft_package_id);

  const existing = sqlite
    .prepare(`
      SELECT *
      FROM matilda_draft_revisions
      WHERE draft_package_id = ?
        AND source_draft_updated_at = ?
      LIMIT 1
    `)
    .get(
      draft.draft_package_id,
      draft.updated_at,
    );

  if (existing) {
    return mapDraftRevision(existing);
  }

  const created_at = new Date().toISOString();
  const draft_revision_id = `draft-revision-${randomUUID()}`;

  sqlite
    .prepare(`
      INSERT INTO matilda_draft_revisions (
        draft_revision_id,
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
        source_draft_status,
        source_draft_updated_at,
        status,
        created_at
      ) VALUES (
        ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
      )
    `)
    .run(
      draft_revision_id,
      draft.draft_package_id,
      draft.lineage_id,
      draft.project_id,
      draft.conversation_id,
      draft.current_interpretation,
      draft.proposed_work,
      draft.proposed_artifacts,
      draft.in_scope,
      draft.out_of_scope,
      draft.constraints,
      draft.expected_outcome,
      draft.unresolved_questions,
      JSON.stringify(draft.evidence_entry_ids),
      draft.status,
      draft.updated_at,
      "approval_review_candidate",
      created_at,
    );

  return getDraftRevisionById(draft_revision_id);
}
