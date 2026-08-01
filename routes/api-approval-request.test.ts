import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";
import fs from "node:fs";
import path from "node:path";

import {
  handleApprovalRequestList,
} from "./api-approval-request";

type CapturedResponse = {
  statusCode: number;
  body: unknown;
};

function createResponseCapture(): {
  response: CapturedResponse;
  res: {
    status(code: number): unknown;
    json(body: unknown): CapturedResponse;
  };
} {
  const response: CapturedResponse = {
    statusCode: 200,
    body: null,
  };

  const res = {
    status(code: number) {
      response.statusCode = code;
      return res;
    },

    json(body: unknown) {
      response.body = body;
      return response;
    },
  };

  return {
    response,
    res,
  };
}

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
      'draft-api-pending',
      'lineage-api-pending',
      'hq',
      'conversation-api',
      'Prepare Approval Request API.',
      'Expose read-only approval requests.',
      'API route and tests.',
      'Canonical Package approval requests.',
      'Decision execution.',
      'Read-only.',
      'One pending approval response.',
      NULL,
      '["evidence-api-1"]',
      'draft_non_authoritative',
      '2026-08-01T07:00:00.000Z',
      '2026-08-01T07:30:00.000Z'
    );
  `);

  db.close();
}

test("rejects a request without project_id", () => {
  const { response, res } = createResponseCapture();

  handleApprovalRequestList(
    {
      query: {},
    },
    res,
  );

  assert.equal(response.statusCode, 400);
  assert.deepEqual(response.body, {
    error: "project_id is required",
  });
});

test("returns a project-scoped Approval Request collection", () => {
  const originalCwd = process.cwd();

  const fixtureRoot = path.join(
    "/tmp",
    `approval-request-api-${process.pid}-${Date.now()}`,
  );

  fs.mkdirSync(
    path.join(fixtureRoot, "db"),
    {
      recursive: true,
    },
  );

  createFixtureDatabase(
    path.join(fixtureRoot, "db", "main.db"),
  );

  process.chdir(fixtureRoot);

  try {
    const { response, res } = createResponseCapture();

    handleApprovalRequestList(
      {
        query: {
          project_id: "hq",
        },
      },
      res,
    );

    assert.equal(response.statusCode, 200);

    const body = response.body as {
      project_id: string;
      requests: Array<{
        approval_request_id: string;
        available_decisions: string[];
      }>;
    };

    assert.equal(body.project_id, "hq");
    assert.equal(body.requests.length, 1);

    assert.equal(
      body.requests[0]?.approval_request_id,
      "canonical_package_approval:draft-api-pending",
    );

    assert.deepEqual(
      body.requests[0]?.available_decisions,
      ["approve_canonical_package"],
    );
  } finally {
    process.chdir(originalCwd);
    fs.rmSync(fixtureRoot, {
      recursive: true,
      force: true,
    });
  }
});
