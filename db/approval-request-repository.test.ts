import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

import { createApprovalRequestRepository } from "./approval-request-repository";

function createFixtureDatabase(databasePath: string): void {
  const db = new Database(databasePath);

  db.exec(`
    CREATE TABLE matilda_living_draft_packages (
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

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT PRIMARY KEY,
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      lineage_id TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      approved_interpretation TEXT NOT NULL,
      approved_work TEXT,
      approved_artifacts TEXT,
      approved_scope TEXT,
      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,
      approval_timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
  `);

  const insertDraft = db.prepare(`
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
  `);

  insertDraft.run({
    draft_package_id: "draft-hq-pending",
    lineage_id: "lineage-hq-pending",
    project_id: "hq",
    conversation_id: "conversation-hq",
    current_interpretation: "Prepare the HQ approval repository.",
    proposed_work: "Build a read-only repository.",
    proposed_artifacts: "Repository and tests.",
    in_scope: "Canonical Package approval requests.",
    out_of_scope: "Decision execution.",
    constraints: "Read-only.",
    expected_outcome: "One pending approval request.",
    unresolved_questions: null,
    evidence_entry_ids: JSON.stringify(["evidence-1"]),
    status: "draft_non_authoritative",
    created_at: "2026-08-01T06:00:00.000Z",
    updated_at: "2026-08-01T07:00:00.000Z",
  });

  insertDraft.run({
    draft_package_id: "draft-hq-completed",
    lineage_id: "lineage-hq-completed",
    project_id: "hq",
    conversation_id: "conversation-hq",
    current_interpretation: "Already approved work.",
    proposed_work: null,
    proposed_artifacts: null,
    in_scope: null,
    out_of_scope: null,
    constraints: null,
    expected_outcome: null,
    unresolved_questions: null,
    evidence_entry_ids: JSON.stringify(["evidence-2"]),
    status: "draft_non_authoritative",
    created_at: "2026-08-01T05:00:00.000Z",
    updated_at: "2026-08-01T05:30:00.000Z",
  });

  insertDraft.run({
    draft_package_id: "draft-other-project",
    lineage_id: "lineage-other-project",
    project_id: "other",
    conversation_id: "conversation-other",
    current_interpretation: "Other project work.",
    proposed_work: null,
    proposed_artifacts: null,
    in_scope: null,
    out_of_scope: null,
    constraints: null,
    expected_outcome: null,
    unresolved_questions: null,
    evidence_entry_ids: JSON.stringify(["evidence-3"]),
    status: "draft_non_authoritative",
    created_at: "2026-08-01T04:00:00.000Z",
    updated_at: "2026-08-01T04:30:00.000Z",
  });

  db.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      summary_id,
      draft_package_id,
      lineage_id,
      project_id,
      conversation_id,
      approved_interpretation,
      approved_work,
      approved_artifacts,
      approved_scope,
      approved_constraints,
      approved_expected_outcome,
      approval_actor,
      approval_timestamp,
      status,
      created_at
    ) VALUES (
      'pkg-hq-completed',
      'summary-hq-completed',
      'draft-hq-completed',
      'lineage-hq-completed',
      'hq',
      'conversation-hq',
      'Already approved work.',
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      'Marcela',
      '2026-08-01T05:45:00.000Z',
      'canonical_approved',
      '2026-08-01T05:45:00.000Z'
    )
  `).run();

  db.close();
}

test("lists only pending Canonical Package approvals for the selected project", () => {
  const databasePath = `/tmp/approval-request-repository-${process.pid}-list.db`;

  createFixtureDatabase(databasePath);

  const repository = createApprovalRequestRepository(databasePath);

  try {
    const records =
      repository.listPendingCanonicalPackageApprovalsByProject("hq");

    assert.equal(records.length, 1);
    assert.equal(records[0]?.draft_package_id, "draft-hq-pending");
  } finally {
    repository.close();
  }
});
