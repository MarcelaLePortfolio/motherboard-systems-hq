import assert from "node:assert/strict";
import {
  mkdtempSync,
  mkdirSync,
  rmSync,
} from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import Database from "better-sqlite3";

type FixtureOptions = {
  expectedOutcome: string | null;
  conflictingGovernanceTarget?: boolean;
};

const repositoryRoot = process.cwd();
const temporaryRoot = mkdtempSync(
  path.join(tmpdir(), "matilda-canonical-package-runtime-test-"),
);
mkdirSync(path.join(temporaryRoot, "db"));

const databasePath = path.join(temporaryRoot, "db", "main.db");
const previousWorkingDirectory = process.cwd();

function initializeFixtureSchema(): void {
  const sqlite = new Database(databasePath);

  sqlite.exec(`
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

    CREATE TABLE matilda_draft_revisions (
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
      UNIQUE (draft_package_id, source_draft_updated_at)
    );

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      draft_revision_id TEXT NOT NULL,
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
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version),
      UNIQUE (draft_revision_id)
    );

    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT NOT NULL,
      conversation_id TEXT,
      requested_outcome TEXT NOT NULL,
      scope TEXT,
      containment TEXT,
      constraints TEXT,
      success_criteria TEXT,
      context TEXT,
      style_presentation_intent TEXT,
      exclusions TEXT,
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );
  `);

  sqlite.close();
}

function resetFixture({
  expectedOutcome,
  conflictingGovernanceTarget = false,
}: FixtureOptions): void {
  const sqlite = new Database(databasePath);

  sqlite.exec(`
    DELETE FROM governance_packages;
    DELETE FROM matilda_canonical_packages;
    DELETE FROM matilda_draft_revisions;
    DELETE FROM matilda_living_draft_packages;
  `);

  sqlite.prepare(`
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
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    "revision-canonical-test",
    "draft-canonical-test",
    "lineage-canonical-test",
    "hq",
    "conversation-canonical-test",
    "Validate Canonical Package approval safely.",
    "Exercise the existing authoritative transition.",
    "Canonical Package and Mission Package projection.",
    "Canonical approval persistence only.",
    "Delegation, validation, execution, and push.",
    "Fail closed without partial authoritative persistence.",
    expectedOutcome,
    null,
    JSON.stringify(["iel-canonical-test"]),
    "draft_non_authoritative",
    "2026-08-31T00:00:00.000Z",
    "approval_review_candidate",
    "2026-08-31T00:00:01.000Z",
  );

  if (conflictingGovernanceTarget) {
    sqlite.prepare(`
      INSERT INTO matilda_canonical_packages (
        package_id,
        package_version,
        summary_id,
        draft_package_id,
        draft_revision_id,
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
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      "pkg-canonical-test",
      1,
      "summary-prior-canonical-test",
      "draft-canonical-test",
      "revision-prior-canonical-test",
      "lineage-canonical-test",
      "hq",
      "conversation-prior-canonical-test",
      "Prior approved interpretation.",
      null,
      null,
      null,
      null,
      "Prior approved outcome.",
      "marcela",
      "2026-08-30T00:00:00.000Z",
      "canonical_approved",
      "2026-08-30T00:00:00.000Z",
    );

    sqlite.prepare(`
      INSERT INTO governance_packages (
        package_id,
        package_version,
        project_id,
        conversation_id,
        requested_outcome,
        created_at
      ) VALUES (?, ?, ?, ?, ?, ?)
    `).run(
      "pkg-canonical-test",
      2,
      "other-project",
      "legacy-conversation",
      "Conflicting legacy outcome.",
      "2026-08-30T00:00:01.000Z",
    );
  }

  sqlite.close();
}

function countRows(table: string): number {
  const sqlite = new Database(databasePath, { readonly: true });

  try {
    const row = sqlite
      .prepare(`SELECT COUNT(*) AS count FROM ${table}`)
      .get() as { count: number };

    return row.count;
  } finally {
    sqlite.close();
  }
}

initializeFixtureSchema();
process.chdir(temporaryRoot);

const runtime = require(
  path.join(repositoryRoot, "db", "matilda-canonical-package-runtime.ts"),
) as typeof import("./matilda-canonical-package-runtime");

test(
  "incomplete expected outcome fails before authoritative persistence",
  () => {
    resetFixture({ expectedOutcome: null });

    assert.throws(
      () =>
        runtime.createCanonicalPackageFromApprovedSummary(
          {
            draft_revision_id: "revision-canonical-test",
            approval_actor: "marcela",
          },
          { schemaReady: true },
        ),
      /requires a non-empty expected_outcome/,
    );

    assert.equal(countRows("matilda_canonical_packages"), 0);
    assert.equal(countRows("governance_packages"), 0);
  },
);

test(
  "projection conflict rolls back Canonical Package persistence",
  () => {
    resetFixture({
      expectedOutcome: "One safely projected Canonical Package.",
      conflictingGovernanceTarget: true,
    });

    assert.throws(
      () =>
        runtime.createCanonicalPackageFromApprovedSummary(
          {
            draft_revision_id: "revision-canonical-test",
            approval_actor: "marcela",
          },
          { schemaReady: true },
        ),
      /conflicting identity, semantics, or provenance/,
    );

    assert.equal(countRows("matilda_canonical_packages"), 1);

    const sqlite = new Database(databasePath, { readonly: true });

    try {
      const row = sqlite.prepare(`
        SELECT
          project_id,
          conversation_id,
          requested_outcome
        FROM governance_packages
        WHERE package_id = ?
          AND package_version = ?
      `).get(
        "pkg-canonical-test",
        2,
      ) as {
        project_id: string;
        conversation_id: string;
        requested_outcome: string;
      };

      assert.deepEqual(row, {
        project_id: "other-project",
        conversation_id: "legacy-conversation",
        requested_outcome: "Conflicting legacy outcome.",
      });

      const canonicalRows = sqlite.prepare(`
        SELECT
          package_id,
          package_version,
          draft_revision_id,
          approved_expected_outcome
        FROM matilda_canonical_packages
        ORDER BY package_version
      `).all() as Array<{
        package_id: string;
        package_version: number;
        draft_revision_id: string;
        approved_expected_outcome: string;
      }>;

      assert.deepEqual(canonicalRows, [
        {
          package_id: "pkg-canonical-test",
          package_version: 1,
          draft_revision_id: "revision-prior-canonical-test",
          approved_expected_outcome: "Prior approved outcome.",
        },
      ]);
    } finally {
      sqlite.close();
    }
  },
);

test(
  "valid approval atomically persists Canonical Package and projection",
  () => {
    resetFixture({
      expectedOutcome: "One safely projected Canonical Package.",
    });

    const result =
      runtime.createCanonicalPackageFromApprovedSummary(
        {
          draft_revision_id: "revision-canonical-test",
          approval_actor: "marcela",
        },
        { schemaReady: true },
      );

    assert.equal(result.status, "canonical_approved");
    assert.equal(
      result.approved_expected_outcome,
      "One safely projected Canonical Package.",
    );
    assert.equal(result.delegation_authorized, false);
    assert.equal(result.validation_authorized, false);
    assert.equal(result.envelope_authorized, false);
    assert.equal(result.execution_authorized, false);

    assert.equal(countRows("matilda_canonical_packages"), 1);
    assert.equal(countRows("governance_packages"), 1);

    const sqlite = new Database(databasePath, { readonly: true });

    try {
      const canonical = sqlite.prepare(`
        SELECT
          project_id,
          conversation_id,
          approved_expected_outcome,
          status
        FROM matilda_canonical_packages
        LIMIT 1
      `).get() as {
        project_id: string;
        conversation_id: string;
        approved_expected_outcome: string;
        status: string;
      };

      const projection = sqlite.prepare(`
        SELECT
          project_id,
          conversation_id,
          requested_outcome
        FROM governance_packages
        LIMIT 1
      `).get() as {
        project_id: string;
        conversation_id: string;
        requested_outcome: string;
      };

      assert.deepEqual(canonical, {
        project_id: "hq",
        conversation_id: "conversation-canonical-test",
        approved_expected_outcome:
          "One safely projected Canonical Package.",
        status: "canonical_approved",
      });

      assert.deepEqual(projection, {
        project_id: "hq",
        conversation_id: "conversation-canonical-test",
        requested_outcome:
          "One safely projected Canonical Package.",
      });
    } finally {
      sqlite.close();
    }
  },
);

test.after(() => {
  process.chdir(previousWorkingDirectory);
  rmSync(temporaryRoot, { recursive: true, force: true });
});
