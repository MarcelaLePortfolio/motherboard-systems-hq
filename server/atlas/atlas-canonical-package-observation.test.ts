import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import Database from "better-sqlite3";

import {
  readAtlasCanonicalPackageObservations,
} from "./atlas-canonical-package-observation";

function createFixtureDatabase() {
  const root = mkdtempSync(
    path.join(
      tmpdir(),
      "atlas-canonical-package-observation-",
    ),
  );

  const databasePath = path.join(root, "main.db");
  const database = new Database(databasePath);

  database.exec(`
    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      draft_revision_id TEXT,
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
      PRIMARY KEY (package_id, package_version)
    );
  `);

  return {
    database,
    databasePath,
    cleanup() {
      database.close();
      rmSync(root, {
        recursive: true,
        force: true,
      });
    },
  };
}

function insertCanonicalPackage(
  database: Database.Database,
  input: {
    projectId: string;
    packageId: string;
    packageVersion: number;
    draftRevisionId: string;
    lineageId: string;
    conversationId: string;
    status?: string;
  },
) {
  database
    .prepare(`
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
    `)
    .run(
      input.packageId,
      input.packageVersion,
      `summary-${input.packageId}`,
      `draft-${input.packageId}`,
      input.draftRevisionId,
      input.lineageId,
      input.projectId,
      input.conversationId,
      "approved interpretation",
      "approved work",
      "approved artifacts",
      "approved scope",
      "approved constraints",
      "approved outcome",
      "marcela",
      "2026-09-16T21:00:00.000Z",
      input.status ?? "canonical_approved",
      "2026-09-16T21:00:00.000Z",
    );
}

test(
  "Atlas observes canonical Package authority directly from canonical source",
  () => {
    const fixture = createFixtureDatabase();

    try {
      insertCanonicalPackage(fixture.database, {
        projectId: "hq",
        packageId: "pkg-1",
        packageVersion: 1,
        draftRevisionId: "revision-1",
        lineageId: "lineage-1",
        conversationId: "conversation-1",
      });

      const observations =
        readAtlasCanonicalPackageObservations(
          "hq",
          fixture.databasePath,
        );

      assert.deepEqual(observations, [
        {
          observationType: "canonical_package",
          authority: "authoritative",
          status: "canonical_approved",
          projectId: "hq",
          conversationId: "conversation-1",
          packageId: "pkg-1",
          packageVersion: 1,
          draftRevisionId: "revision-1",
          lineageId: "lineage-1",
          approvalActor: "marcela",
          approvalTimestamp:
            "2026-09-16T21:00:00.000Z",
        },
      ]);
    } finally {
      fixture.cleanup();
    }
  },
);

test(
  "Atlas canonical Package observation fails closed across project scope",
  () => {
    const fixture = createFixtureDatabase();

    try {
      insertCanonicalPackage(fixture.database, {
        projectId: "other-project",
        packageId: "pkg-other",
        packageVersion: 1,
        draftRevisionId: "revision-other",
        lineageId: "lineage-other",
        conversationId: "conversation-other",
      });

      assert.deepEqual(
        readAtlasCanonicalPackageObservations(
          "hq",
          fixture.databasePath,
        ),
        [],
      );
    } finally {
      fixture.cleanup();
    }
  },
);

test(
  "Atlas does not promote non-canonical Package state",
  () => {
    const fixture = createFixtureDatabase();

    try {
      insertCanonicalPackage(fixture.database, {
        projectId: "hq",
        packageId: "pkg-pending",
        packageVersion: 1,
        draftRevisionId: "revision-pending",
        lineageId: "lineage-pending",
        conversationId: "conversation-pending",
        status: "pending",
      });

      assert.deepEqual(
        readAtlasCanonicalPackageObservations(
          "hq",
          fixture.databasePath,
        ),
        [],
      );
    } finally {
      fixture.cleanup();
    }
  },
);

test(
  "Atlas canonical Package observation requires project identity",
  () => {
    const fixture = createFixtureDatabase();

    try {
      assert.throws(
        () =>
          readAtlasCanonicalPackageObservations(
            "   ",
            fixture.databasePath,
          ),
        /requires projectId/,
      );
    } finally {
      fixture.cleanup();
    }
  },
);
