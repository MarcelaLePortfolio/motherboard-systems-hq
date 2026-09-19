import assert from "node:assert/strict";
import test, { after } from "node:test";
import Database from "better-sqlite3";
import fs from "node:fs";
import path from "node:path";

import type { ApprovalRequestSourceRecord } from "./approval-request-repository";

const originalCwd = process.cwd();
const fixtureRoot = path.join(
  "/tmp",
  `approval-request-assembler-${process.pid}-${Date.now()}`,
);

fs.mkdirSync(path.join(fixtureRoot, "db"), {
  recursive: true,
});

const fixtureDb = new Database(
  path.join(fixtureRoot, "db", "main.db"),
);

fixtureDb.exec(`
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
`);

const insertDraft = fixtureDb.prepare(`
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
    'hq',
    'conversation-hq',
    'Prepare the Approval Request read model.',
    'Assemble an executive-facing read model.',
    'Approval Request model and tests.',
    'Canonical Package approval projection.',
    'Decision execution.',
    'Read-only and project-scoped.',
    'One deterministic pending request.',
    NULL,
    '["evidence-1","evidence-2"]',
    'draft_non_authoritative',
    '2026-08-01T07:00:00.000Z',
    @updated_at
  )
`);

for (const [draft_package_id, lineage_id, updated_at] of [
  [
    "draft-hq-pending",
    "lineage-hq-pending",
    "2026-08-01T07:30:00.000Z",
  ],
  [
    "draft-1",
    "lineage-hq-pending",
    "2026-08-01T07:31:00.000Z",
  ],
  [
    "draft-2",
    "lineage-hq-pending",
    "2026-08-01T07:32:00.000Z",
  ],
]) {
  insertDraft.run({
    draft_package_id,
    lineage_id,
    updated_at,
  });
}

fixtureDb.close();
process.chdir(fixtureRoot);

const {
  assembleApprovalRequestReadCollection,
  assembleApprovalRequestReadModel,
} = require("./approval-request-model-assembler");

after(() => {
  process.chdir(originalCwd);
  fs.rmSync(fixtureRoot, {
    recursive: true,
    force: true,
  });
});

function createSource(
  overrides: Partial<ApprovalRequestSourceRecord> = {},
): ApprovalRequestSourceRecord {
  return {
    draft_package_id: "draft-hq-pending",
    lineage_id: "lineage-hq-pending",
    project_id: "hq",
    conversation_id: "conversation-hq",
    current_interpretation: "Prepare the Approval Request read model.",
    proposed_work: "Assemble an executive-facing read model.",
    proposed_artifacts: "Approval Request model and tests.",
    in_scope: "Canonical Package approval projection.",
    out_of_scope: "Decision execution.",
    constraints: "Read-only and project-scoped.",
    expected_outcome: "One deterministic pending request.",
    unresolved_questions: null,
    evidence_entry_ids: JSON.stringify([
      "evidence-1",
      "evidence-2",
      "evidence-1",
    ]),
    source_draft_status: "draft_non_authoritative",
    created_at: "2026-08-01T07:00:00.000Z",
    updated_at: "2026-08-01T07:30:00.000Z",
    ...overrides,
  };
}

test("assembles a deterministic Approval Request", () => {
  const request =
    assembleApprovalRequestReadModel(createSource());

  assert.equal(
    request.approval_request_id,
    "canonical_package_approval:draft-hq-pending",
  );

  assert.match(
    request.draft_revision_id,
    /^draft-revision-/,
  );

  assert.deepEqual(
    request.available_decisions,
    ["approve_canonical_package"],
  );

  assert.deepEqual(
    request.evidence.evidence_entry_ids,
    ["evidence-1", "evidence-2"],
  );
});

test("assembles a project-scoped collection", () => {
  const collection =
    assembleApprovalRequestReadCollection("hq", [
      createSource({ draft_package_id: "draft-1" }),
      createSource({ draft_package_id: "draft-2" }),
    ]);

  assert.equal(collection.project_id, "hq");
  assert.equal(collection.requests.length, 2);

  for (const request of collection.requests) {
    assert.match(
      request.draft_revision_id,
      /^draft-revision-/,
    );
  }
});

test("rejects cross-project sources", () => {
  assert.throws(
    () =>
      assembleApprovalRequestReadCollection("hq", [
        createSource({ project_id: "other" }),
      ]),
    /project does not match/,
  );
});

test("rejects invalid evidence JSON", () => {
  assert.throws(
    () =>
      assembleApprovalRequestReadModel(
        createSource({
          evidence_entry_ids: "not-json",
        }),
      ),
    /invalid evidence_entry_ids JSON/,
  );
});
