#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="44e84e8d4"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

cat > db/canonical-package-read-repository.delegation.test.ts << 'TS'
import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import Database from "better-sqlite3";

import {
  createCanonicalPackageReadRepository,
} from "./canonical-package-read-repository";

function createFixtureDatabase(): string {
  const dir = fs.mkdtempSync(
    path.join(os.tmpdir(), "executive-delegation-read-"),
  );
  const databasePath = path.join(dir, "fixture.db");
  const db = new Database(databasePath);

  db.exec(`
    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      draft_revision_id TEXT,
      lineage_id TEXT NOT NULL,
      project_id TEXT NOT NULL,
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

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
  `);

  db.prepare(`
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
    ) VALUES (
      'pkg-1',
      1,
      'summary-1',
      'draft-1',
      'revision-1',
      'lineage-1',
      'hq',
      'conversation-1',
      'Approved interpretation',
      'Approved work',
      'Approved artifacts',
      'Approved scope',
      'Approved constraints',
      'Approved outcome',
      'marcela',
      '2026-09-22T20:00:00.000Z',
      'canonical_approved',
      '2026-09-22T20:00:00.000Z'
    )
  `).run();

  db.close();
  return databasePath;
}

function insertDelegation(
  databasePath: string,
  input: {
    delegation_id: string;
    authorization_state: string;
    authorization_timestamp?: string;
    delegated_by?: string;
    created_at?: string;
  },
): void {
  const db = new Database(databasePath);

  db.prepare(`
    INSERT INTO governance_delegations (
      delegation_id,
      project_id,
      package_id,
      package_version,
      authorization_state,
      authorization_timestamp,
      delegated_by,
      created_at
    ) VALUES (
      @delegation_id,
      'hq',
      'pkg-1',
      1,
      @authorization_state,
      @authorization_timestamp,
      @delegated_by,
      @created_at
    )
  `).run({
    delegation_id: input.delegation_id,
    authorization_state: input.authorization_state,
    authorization_timestamp:
      input.authorization_timestamp ??
      "2026-09-22T20:05:00.000Z",
    delegated_by: input.delegated_by ?? "marcela",
    created_at:
      input.created_at ??
      "2026-09-22T20:05:00.000Z",
  });

  db.close();
}

test("approved package with no delegation is awaiting delegation", () => {
  const databasePath = createFixtureDatabase();
  const repository =
    createCanonicalPackageReadRepository(databasePath);

  try {
    const [pkg] = repository.listByProject("hq");

    assert.ok(pkg);
    assert.deepEqual(pkg.delegation, {
      state: "awaiting_delegation",
      delegation_id: null,
      authorization_state: null,
      authorization_timestamp: null,
      delegated_by: null,
    });
  } finally {
    repository.close();
  }
});

test("exactly one authorized delegation is rendered as delegated", () => {
  const databasePath = createFixtureDatabase();

  insertDelegation(databasePath, {
    delegation_id: "delegation-1",
    authorization_state: "AUTHORIZED",
    authorization_timestamp: "2026-09-22T20:05:00.000Z",
    delegated_by: "marcela",
  });

  const repository =
    createCanonicalPackageReadRepository(databasePath);

  try {
    const [pkg] = repository.listByProject("hq");

    assert.ok(pkg);
    assert.deepEqual(pkg.delegation, {
      state: "delegated",
      delegation_id: "delegation-1",
      authorization_state: "AUTHORIZED",
      authorization_timestamp: "2026-09-22T20:05:00.000Z",
      delegated_by: "marcela",
    });
  } finally {
    repository.close();
  }
});

test("multiple matching delegations fail closed as ambiguous", () => {
  const databasePath = createFixtureDatabase();

  insertDelegation(databasePath, {
    delegation_id: "delegation-1",
    authorization_state: "AUTHORIZED",
    created_at: "2026-09-22T20:05:00.000Z",
  });

  insertDelegation(databasePath, {
    delegation_id: "delegation-2",
    authorization_state: "AUTHORIZED",
    created_at: "2026-09-22T20:06:00.000Z",
  });

  const repository =
    createCanonicalPackageReadRepository(databasePath);

  try {
    const [pkg] = repository.listByProject("hq");

    assert.ok(pkg);
    assert.deepEqual(pkg.delegation, {
      state: "ambiguous",
      delegation_id: null,
      authorization_state: null,
      authorization_timestamp: null,
      delegated_by: null,
    });
  } finally {
    repository.close();
  }
});

test("non-authorized matching delegation fails closed as ambiguous", () => {
  const databasePath = createFixtureDatabase();

  insertDelegation(databasePath, {
    delegation_id: "delegation-1",
    authorization_state: "PENDING",
  });

  const repository =
    createCanonicalPackageReadRepository(databasePath);

  try {
    const [pkg] = repository.listByProject("hq");

    assert.ok(pkg);
    assert.equal(pkg.delegation.state, "ambiguous");
  } finally {
    repository.close();
  }
});
TS

cat > client/src/approvals/governanceDelegationApi.test.ts << 'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  delegateCanonicalPackage,
} from "./governanceDelegationApi";

test("delegation adapter posts exact package identity to existing governance route", async () => {
  const originalFetch = globalThis.fetch;
  let capturedUrl: string | URL | Request | null = null;
  let capturedInit: RequestInit | undefined;

  globalThis.fetch = async (
    input: string | URL | Request,
    init?: RequestInit,
  ) => {
    capturedUrl = input;
    capturedInit = init;

    return new Response(
      JSON.stringify({
        ok: true,
        findings: [],
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  };

  try {
    await delegateCanonicalPackage({
      delegation_id: "delegation-test",
      project_id: "hq",
      package_id: "pkg-test",
      package_version: 7,
      authorization_state: "AUTHORIZED",
      authorization_timestamp: "2026-09-22T20:10:00.000Z",
      delegated_by: "marcela",
    });

    assert.equal(
      capturedUrl,
      "/api/governance/delegation",
    );
    assert.equal(capturedInit?.method, "POST");

    const body = JSON.parse(
      String(capturedInit?.body),
    );

    assert.deepEqual(body, {
      delegation_id: "delegation-test",
      project_id: "hq",
      package_id: "pkg-test",
      package_version: 7,
      authorization_state: "AUTHORIZED",
      authorization_timestamp: "2026-09-22T20:10:00.000Z",
      delegated_by: "marcela",
    });
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("delegation adapter rejects invalid package version before mutation", async () => {
  const originalFetch = globalThis.fetch;
  let fetchCalled = false;

  globalThis.fetch = async () => {
    fetchCalled = true;
    throw new Error("fetch should not be called");
  };

  try {
    await assert.rejects(
      delegateCanonicalPackage({
        delegation_id: "delegation-test",
        project_id: "hq",
        package_id: "pkg-test",
        package_version: 0,
        authorization_state: "AUTHORIZED",
        authorization_timestamp: "2026-09-22T20:10:00.000Z",
        delegated_by: "marcela",
      }),
      /positive integer/,
    );

    assert.equal(fetchCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TS

git diff --check -- \
  db/canonical-package-read-repository.delegation.test.ts \
  client/src/approvals/governanceDelegationApi.test.ts

npm run build

node --import tsx --test \
  db/canonical-package-read-repository.delegation.test.ts

node --import tsx --test \
  client/src/approvals/governanceDelegationApi.test.ts

(
  cd client
  npm run build
)

git add -- \
  db/canonical-package-read-repository.delegation.test.ts \
  client/src/approvals/governanceDelegationApi.test.ts

git commit -m "Add focused Executive Delegation behavioral tests"
git push origin "$BRANCH"
