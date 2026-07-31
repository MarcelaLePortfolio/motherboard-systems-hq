import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { createServer, type Server } from "node:http";
import { tmpdir } from "node:os";
import { join } from "node:path";

import Database from "better-sqlite3";
import express from "express";

import { createPackageReadRouter } from "./api-package-read";

const tempDir = mkdtempSync(join(tmpdir(), "package-read-api-"));
const databasePath = join(tempDir, "test.db");

const sqlite = new Database(databasePath);

sqlite.exec(`
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

const insert = sqlite.prepare(`
  INSERT INTO matilda_living_draft_packages (
    draft_package_id,
    lineage_id,
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
    updated_at,
    project_id,
    conversation_id
  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
`);

insert.run(
  "draft-hq-new",
  "lineage-hq-new",
  "Newest HQ interpretation",
  "Newest HQ work",
  null,
  "Read-only package scope",
  "Package mutations",
  "Preserve authority boundaries",
  "Newest HQ outcome",
  null,
  '["evidence-2"]',
  "draft_non_authoritative",
  "2026-07-31T10:00:00.000Z",
  "2026-07-31T11:00:00.000Z",
  "hq",
  "conversation-hq-new",
);

insert.run(
  "draft-hq-old",
  "lineage-hq-old",
  "Older HQ interpretation",
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  '["evidence-1"]',
  "draft_non_authoritative",
  "2026-07-30T10:00:00.000Z",
  "2026-07-30T11:00:00.000Z",
  "hq",
  "conversation-hq-old",
);

insert.run(
  "draft-other",
  "lineage-other",
  "Other project interpretation",
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  "[]",
  "draft_non_authoritative",
  "2026-07-31T09:00:00.000Z",
  "2026-07-31T12:00:00.000Z",
  "other",
  "conversation-other",
);

sqlite.close();

const app = express();
app.use(express.json());
app.use(createPackageReadRouter(databasePath));

const server: Server = createServer(app);

async function listen(): Promise<number> {
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();

      if (!address || typeof address === "string") {
        reject(new Error("Unable to resolve test server address."));
        return;
      }

      resolve(address.port);
    });
  });
}

async function close(): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    server.close((error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });
}

async function run() {
  const port = await listen();
  const baseUrl = `http://127.0.0.1:${port}`;

  const missingProjectResponse = await fetch(
    `${baseUrl}/api/package-read`,
  );
  const missingProjectBody = await missingProjectResponse.json();

  assert.equal(missingProjectResponse.status, 400);
  assert.equal(missingProjectBody.ok, false);

  const listResponse = await fetch(
    `${baseUrl}/api/package-read?project_id=hq`,
  );
  const listBody = await listResponse.json();

  assert.equal(listResponse.status, 200);
  assert.equal(listBody.ok, true);
  assert.equal(listBody.package_collection.project_id, "hq");
  assert.equal(listBody.package_collection.packages.length, 2);
  assert.equal(
    listBody.package_collection.packages[0].id,
    "draft-hq-new",
  );
  assert.ok(
    listBody.package_collection.packages.every(
      (item: { project_id: string }) => item.project_id === "hq",
    ),
  );

  const detailResponse = await fetch(
    `${baseUrl}/api/package-read/draft-hq-new?project_id=hq`,
  );
  const detailBody = await detailResponse.json();

  assert.equal(detailResponse.status, 200);
  assert.equal(detailBody.ok, true);
  assert.equal(detailBody.package.id, "draft-hq-new");
  assert.equal(detailBody.package.status, "needs_review");
  assert.equal(
    detailBody.package.conversation_id,
    "conversation-hq-new",
  );

  const wrongProjectResponse = await fetch(
    `${baseUrl}/api/package-read/draft-hq-new?project_id=other`,
  );
  const wrongProjectBody = await wrongProjectResponse.json();

  assert.equal(wrongProjectResponse.status, 404);
  assert.equal(wrongProjectBody.ok, false);

  const missingResponse = await fetch(
    `${baseUrl}/api/package-read/missing?project_id=hq`,
  );
  const missingBody = await missingResponse.json();

  assert.equal(missingResponse.status, 404);
  assert.equal(missingBody.ok, false);

  console.log("Package Read API tests passed.");
}

run()
  .finally(async () => {
    await close();
    rmSync(tempDir, { recursive: true, force: true });
  })
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
