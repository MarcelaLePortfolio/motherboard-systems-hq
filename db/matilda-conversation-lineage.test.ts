import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import Database from "better-sqlite3";

test("conversation identity remains explicit across IEL and Living Draft lineage", () => {
  const repositoryRoot = process.cwd();
  const temporaryRoot = mkdtempSync(
    path.join(tmpdir(), "matilda-lineage-test-")
  );

  mkdirSync(path.join(temporaryRoot, "db"));

  const databasePath = path.join(temporaryRoot, "db", "main.db");
  const seedDatabase = new Database(databasePath);

  seedDatabase.exec(`
    CREATE TABLE matilda_interpretation_evidence_ledger (
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

    CREATE TABLE matilda_living_draft_packages (
      draft_package_id TEXT PRIMARY KEY,
      lineage_id TEXT NOT NULL,
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

    CREATE TABLE matilda_conversation_turns (
      turn_id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      conversation_id TEXT,
      user_message TEXT NOT NULL,
      assistant_reply TEXT NOT NULL,
      interpretation_entry_id TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    INSERT INTO matilda_interpretation_evidence_ledger (
      entry_id,
      created_at,
      actor,
      interpretation_event,
      minimum_sufficient_context,
      supporting_raw_evidence,
      matilda_observation,
      supersession_status
    ) VALUES (
      'iel-backfill',
      '2026-07-23T00:00:00.000Z',
      'matilda',
      'Backfill validation',
      'Bounded test context',
      'Test evidence',
      'Test observation',
      'current'
    );

    INSERT INTO matilda_conversation_turns (
      turn_id,
      project_id,
      conversation_id,
      user_message,
      assistant_reply,
      interpretation_entry_id,
      created_at
    ) VALUES (
      'turn-backfill',
      'hq',
      'conversation-hq-test',
      'Test message',
      'Test reply',
      'iel-backfill',
      '2026-07-23T00:00:01.000Z'
    );

    INSERT INTO matilda_living_draft_packages (
      draft_package_id,
      lineage_id,
      current_interpretation,
      evidence_entry_ids,
      status,
      created_at,
      updated_at
    ) VALUES (
      'draft-backfill',
      'lineage-backfill',
      'Backfill test',
      '["iel-backfill"]',
      'draft_non_authoritative',
      '2026-07-23T00:00:02.000Z',
      '2026-07-23T00:00:02.000Z'
    );
  `);

  seedDatabase.close();

  try {
    process.chdir(temporaryRoot);

    const interpretationRuntime = require(
      path.join(repositoryRoot, "db", "matilda-interpretation-runtime.ts")
    );

    const livingDraftRuntime = require(
      path.join(repositoryRoot, "db", "matilda-living-draft-runtime.ts")
    );

    const draftSynthesisRuntime = require(
      path.join(repositoryRoot, "db", "matilda-draft-synthesis-runtime.ts")
    );

    interpretationRuntime.listInterpretationEvidenceLedgerEntries(20);
    livingDraftRuntime.listLivingDraftPackages(20);

    const database = new Database(databasePath);

    const backfilledIel = database
      .prepare(`
        SELECT project_id, conversation_id
        FROM matilda_interpretation_evidence_ledger
        WHERE entry_id = 'iel-backfill'
      `)
      .get() as {
      project_id: string;
      conversation_id: string;
    };

    assert.deepEqual(backfilledIel, {
      project_id: "hq",
      conversation_id: "conversation-hq-test",
    });

    const backfilledDraft = database
      .prepare(`
        SELECT project_id, conversation_id
        FROM matilda_living_draft_packages
        WHERE draft_package_id = 'draft-backfill'
      `)
      .get() as {
      project_id: string;
      conversation_id: string;
    };

    assert.deepEqual(backfilledDraft, {
      project_id: "hq",
      conversation_id: "conversation-hq-test",
    });

    interpretationRuntime.createInterpretationEvidenceLedgerEntry({
      entry_id: "iel-explicit",
      actor: "matilda",
      project_id: "hq",
      conversation_id: "conversation-hq-test",
      interpretation_event: "Explicit lineage validation",
      minimum_sufficient_context: "Bounded test context",
      supporting_raw_evidence: "Explicit test evidence",
      matilda_observation: "Explicit test observation",
    });

    livingDraftRuntime.upsertLivingDraftPackage({
      draft_package_id: "draft-explicit",
      lineage_id: "lineage-explicit",
      project_id: "hq",
      conversation_id: "conversation-hq-test",
      current_interpretation: "Explicit lineage test",
      evidence_entry_ids: ["iel-explicit"],
      status: "draft_non_authoritative",
    });

    const explicitChain = database
      .prepare(`
        SELECT
          i.project_id AS iel_project,
          i.conversation_id AS iel_conversation,
          d.project_id AS draft_project,
          d.conversation_id AS draft_conversation
        FROM matilda_interpretation_evidence_ledger AS i
        JOIN matilda_living_draft_packages AS d
          ON EXISTS (
            SELECT 1
            FROM json_each(d.evidence_entry_ids)
            WHERE value = i.entry_id
          )
        WHERE i.entry_id = 'iel-explicit'
          AND d.draft_package_id = 'draft-explicit'
      `)
      .get();

    assert.deepEqual(explicitChain, {
      iel_project: "hq",
      iel_conversation: "conversation-hq-test",
      draft_project: "hq",
      draft_conversation: "conversation-hq-test",
    });

    interpretationRuntime.createInterpretationEvidenceLedgerEntry({
      entry_id: "iel-foreign-conversation",
      actor: "matilda",
      project_id: "hq",
      conversation_id: "conversation-hq-other",
      interpretation_event: "Cross-conversation isolation validation",
      minimum_sufficient_context: "Bounded test context",
      supporting_raw_evidence: "Foreign conversation evidence",
      matilda_observation: "Must not enter another conversation's draft",
    });

    assert.throws(
      () =>
        draftSynthesisRuntime.synthesizeLivingDraft({
          draft_package_id: "draft-cross-conversation",
          lineage_id: "lineage-cross-conversation",
          project_id: "hq",
          conversation_id: "conversation-hq-test",
          evidence_entry_ids: [
            "iel-explicit",
            "iel-foreign-conversation",
          ],
        }),
      /does not belong to the requested project conversation/,
    );

    const crossConversationDraftCount = database
      .prepare(`
        SELECT COUNT(*) AS count
        FROM matilda_living_draft_packages
        WHERE draft_package_id = 'draft-cross-conversation'
      `)
      .get() as { count: number };

    assert.equal(crossConversationDraftCount.count, 0);

    database.close();
  } finally {
    process.chdir(repositoryRoot);
    rmSync(temporaryRoot, { recursive: true, force: true });
  }
});
