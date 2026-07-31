import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import Database from "better-sqlite3";

import { createPackageReadRepository } from "./package-read-repository";

const tempDir = mkdtempSync(join(tmpdir(), "package-read-"));
const dbPath = join(tempDir, "test.db");

const db = new Database(dbPath);

db.exec(`
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
  updated_at TEXT NOT NULL,
  project_id TEXT,
  conversation_id TEXT
);
`);

const insert = db.prepare(`
INSERT INTO matilda_living_draft_packages VALUES (
?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
);
`);

insert.run(
  "draft-new",
  "lineage-new",
  "Newest",
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  "[]",
  "draft",
  "2026-07-31",
  "2026-07-31T11:00:00Z",
  "hq",
  "conversation-new",
);

insert.run(
  "draft-old",
  "lineage-old",
  "Older",
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  "[]",
  "draft",
  "2026-07-30",
  "2026-07-30T11:00:00Z",
  "hq",
  "conversation-old",
);

insert.run(
  "draft-other",
  "lineage-other",
  "Other",
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  "[]",
  "draft",
  "2026-07-31",
  "2026-07-31T12:00:00Z",
  "other",
  "conversation-other",
);

db.close();

const repository = createPackageReadRepository(dbPath);

try {
  const list = repository.listLivingDraftPackagesByProject("hq");

  assert.equal(list.length, 2);
  assert.equal(list[0].draft_package_id, "draft-new");
  assert.equal(list[1].draft_package_id, "draft-old");

  const detail = repository.getLivingDraftPackageById(
    "hq",
    "draft-new",
  );

  assert.equal(detail?.conversation_id, "conversation-new");

  assert.equal(
    repository.getLivingDraftPackageById(
      "other",
      "draft-new",
    ),
    null,
  );

  console.log("Package Read repository tests passed.");
} finally {
  repository.close();
  rmSync(tempDir, { recursive: true, force: true });
}
