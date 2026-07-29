import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import Database from "better-sqlite3";

test("reconciled intent derives authoritative identity and meaning from the Living Draft", () => {
  const repositoryRoot = process.cwd();
  const temporaryRoot = mkdtempSync(
    path.join(tmpdir(), "matilda-reconciled-intent-test-"),
  );

  mkdirSync(path.join(temporaryRoot, "db"));

  const databasePath = path.join(temporaryRoot, "db", "main.db");
  const database = new Database(databasePath);

  database.exec(`
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
      'draft-reconciled-test',
      'lineage-reconciled-test',
      'hq',
      'conversation-hq-reconciled',
      'Preserve project-scoped intent through canonicalization.',
      'Bridge the Living Draft into Reconciled Intent.',
      'Reconciled Intent Summary',
      'Living Draft reconciliation only.',
      'Delegation, governance, envelope creation, and execution.',
      'Remain non-authoritative until explicit approval.',
      'A reviewable summary derived from authoritative draft state.',
      'Confirm approval before canonical package creation.',
      '["iel-one","iel-two"]',
      'draft_non_authoritative',
      '2026-07-29T00:00:00.000Z',
      '2026-07-29T00:00:01.000Z'
    );
  `);

  database.close();

  const previousWorkingDirectory = process.cwd();

  try {
    process.chdir(temporaryRoot);

    const runtime = require(
      path.join(repositoryRoot, "db", "matilda-reconciled-intent-runtime.ts"),
    );

    const summary = runtime.generateReconciledIntentSummary({
      draft_package_id: "draft-reconciled-test",
    });

    assert.equal(summary.draft_package_id, "draft-reconciled-test");
    assert.equal(summary.lineage_id, "lineage-reconciled-test");
    assert.equal(summary.project_id, "hq");
    assert.equal(summary.conversation_id, "conversation-hq-reconciled");
    assert.equal(
      summary.interpreted_objective,
      "Preserve project-scoped intent through canonicalization.",
    );
    assert.equal(
      summary.proposed_work,
      "Bridge the Living Draft into Reconciled Intent.",
    );
    assert.equal(summary.proposed_artifacts, "Reconciled Intent Summary");
    assert.equal(summary.in_scope, "Living Draft reconciliation only.");
    assert.equal(
      summary.out_of_scope,
      "Delegation, governance, envelope creation, and execution.",
    );
    assert.equal(
      summary.constraints,
      "Remain non-authoritative until explicit approval.",
    );
    assert.equal(
      summary.expected_outcome,
      "A reviewable summary derived from authoritative draft state.",
    );
    assert.equal(
      summary.unresolved_questions,
      "Confirm approval before canonical package creation.",
    );
    assert.deepEqual(summary.evidence_entry_ids, ["iel-one", "iel-two"]);
    assert.equal(summary.source_draft_status, "draft_non_authoritative");
    assert.equal(summary.approval_required, true);
    assert.match(summary.summary_id, /^[0-9a-f-]{36}$/i);
    assert.ok(Date.parse(summary.generated_at));

    assert.throws(
      () =>
        runtime.generateReconciledIntentSummary({
          draft_package_id: "missing-draft",
        }),
      /Living Draft Package not found: missing-draft/,
    );

    assert.throws(
      () => runtime.generateReconciledIntentSummary({}),
      /draft_package_id is required/,
    );
  } finally {
    process.chdir(previousWorkingDirectory);
    rmSync(temporaryRoot, { recursive: true, force: true });
  }
});
