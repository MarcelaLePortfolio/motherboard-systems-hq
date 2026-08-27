#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="17ff7424a"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== IMPLEMENT CORRIDOR 6 — EXECUTION APPROVAL TRANSITION UNIT ==="
echo "MODE=EXECUTION"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo

cat > db/governance-execution-approval-persistence.ts << 'FILEEOF'
import type { Database } from "better-sqlite3";

export type VersionControlAuthorization = {
  commit_authorized: boolean;
  push_authorized: boolean;
  remote: string;
  branch: string;
};

export type CreateGovernanceExecutionApprovalInput = {
  approval_id: string;
  envelope_id: string;
  package_id: string;
  package_version: number;
  approved_by: string;
  approval_scope: string;
  commit_authorized: boolean;
  push_authorized: boolean;
  remote: string;
  branch: string;
  issued_at: string;
  expires_at?: string | null;
  justification?: string | null;
};

export type PersistedGovernanceExecutionApproval = {
  approval_id: string;
  envelope_id: string;
  package_id: string;
  package_version: number;
  approved_by: string;
  approval_scope: string;
  commit_authorized: boolean;
  push_authorized: boolean;
  remote: string;
  branch: string;
  issued_at: string;
  expires_at: string | null;
  justification: string | null;
  status: "approved";
  created_at: string;
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required execution approval field: ${field}`);
  }

  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required execution approval field: package_version",
    );
  }

  return Number(value);
}

function validateTimestamp(value: unknown, field: string): string {
  const normalized = requireText(value, field);

  if (Number.isNaN(Date.parse(normalized))) {
    throw new Error(`Invalid execution approval timestamp: ${field}`);
  }

  return normalized;
}

export function ensureGovernanceExecutionApprovalTable(
  db: Database,
): void {
  db.exec(`
    CREATE TABLE IF NOT EXISTS governance_execution_approvals (
      approval_id TEXT PRIMARY KEY,
      envelope_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      approved_by TEXT NOT NULL,
      approval_scope TEXT NOT NULL,
      commit_authorized INTEGER NOT NULL,
      push_authorized INTEGER NOT NULL,
      remote TEXT NOT NULL,
      branch TEXT NOT NULL,
      issued_at TEXT NOT NULL,
      expires_at TEXT,
      justification TEXT,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (envelope_id)
        REFERENCES governance_envelopes(envelope_id),
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      CHECK (status = 'approved'),
      CHECK (commit_authorized IN (0, 1)),
      CHECK (push_authorized IN (0, 1))
    );

    CREATE UNIQUE INDEX IF NOT EXISTS
      idx_governance_execution_approvals_envelope_approval
      ON governance_execution_approvals (
        envelope_id,
        approval_id
      );
  `);
}

export function persistGovernanceExecutionApproval(
  db: Database,
  input: CreateGovernanceExecutionApprovalInput,
): PersistedGovernanceExecutionApproval {
  ensureGovernanceExecutionApprovalTable(db);

  const approval_id = requireText(input.approval_id, "approval_id");
  const envelope_id = requireText(input.envelope_id, "envelope_id");
  const package_id = requireText(input.package_id, "package_id");
  const package_version = requirePackageVersion(input.package_version);
  const approved_by = requireText(input.approved_by, "approved_by");
  const approval_scope = requireText(input.approval_scope, "approval_scope");
  const remote = requireText(input.remote, "remote");
  const branch = requireText(input.branch, "branch");
  const issued_at = validateTimestamp(input.issued_at, "issued_at");

  if (
    input.expires_at !== undefined &&
    input.expires_at !== null
  ) {
    validateTimestamp(input.expires_at, "expires_at");
  }

  if (
    input.push_authorized === true &&
    input.commit_authorized !== true
  ) {
    throw new Error(
      "Execution approval push authority requires commit authority.",
    );
  }

  const envelope = db
    .prepare(`
      SELECT
        envelope_id,
        package_id,
        package_version
      FROM governance_envelopes
      WHERE envelope_id = ?
      LIMIT 1
    `)
    .get(envelope_id) as
      | {
          envelope_id: string;
          package_id: string;
          package_version: number;
        }
      | undefined;

  if (!envelope) {
    throw new Error(`Governance envelope not found: ${envelope_id}`);
  }

  if (
    envelope.package_id !== package_id ||
    envelope.package_version !== package_version
  ) {
    throw new Error(
      "Execution approval package lineage does not match governance envelope.",
    );
  }

  const existing = db
    .prepare(`
      SELECT approval_id
      FROM governance_execution_approvals
      WHERE approval_id = ?
      LIMIT 1
    `)
    .get(approval_id) as { approval_id: string } | undefined;

  if (existing) {
    throw new Error(
      `Execution approval already exists: ${approval_id}`,
    );
  }

  const created_at = new Date().toISOString();

  db.prepare(`
    INSERT INTO governance_execution_approvals (
      approval_id,
      envelope_id,
      package_id,
      package_version,
      approved_by,
      approval_scope,
      commit_authorized,
      push_authorized,
      remote,
      branch,
      issued_at,
      expires_at,
      justification,
      status,
      created_at
    ) VALUES (
      @approval_id,
      @envelope_id,
      @package_id,
      @package_version,
      @approved_by,
      @approval_scope,
      @commit_authorized,
      @push_authorized,
      @remote,
      @branch,
      @issued_at,
      @expires_at,
      @justification,
      'approved',
      @created_at
    )
  `).run({
    approval_id,
    envelope_id,
    package_id,
    package_version,
    approved_by,
    approval_scope,
    commit_authorized: input.commit_authorized ? 1 : 0,
    push_authorized: input.push_authorized ? 1 : 0,
    remote,
    branch,
    issued_at,
    expires_at: input.expires_at ?? null,
    justification: input.justification ?? null,
    created_at,
  });

  return loadGovernanceExecutionApproval(
    db,
    approval_id,
    envelope_id,
  );
}

export function loadGovernanceExecutionApproval(
  db: Database,
  approvalId: string,
  envelopeId: string,
): PersistedGovernanceExecutionApproval {
  ensureGovernanceExecutionApprovalTable(db);

  const approval_id = requireText(approvalId, "approval_id");
  const envelope_id = requireText(envelopeId, "envelope_id");

  const row = db
    .prepare(`
      SELECT
        approval_id,
        envelope_id,
        package_id,
        package_version,
        approved_by,
        approval_scope,
        commit_authorized,
        push_authorized,
        remote,
        branch,
        issued_at,
        expires_at,
        justification,
        status,
        created_at
      FROM governance_execution_approvals
      WHERE approval_id = ?
        AND envelope_id = ?
      LIMIT 2
    `)
    .all(approval_id, envelope_id) as Array<{
      approval_id: string;
      envelope_id: string;
      package_id: string;
      package_version: number;
      approved_by: string;
      approval_scope: string;
      commit_authorized: number;
      push_authorized: number;
      remote: string;
      branch: string;
      issued_at: string;
      expires_at: string | null;
      justification: string | null;
      status: string;
      created_at: string;
    }>;

  if (row.length !== 1) {
    throw new Error(
      `Execution approval not found or ambiguous: ${approval_id} / ${envelope_id}`,
    );
  }

  const approval = row[0];

  if (approval.status !== "approved") {
    throw new Error(
      `Execution approval is not approved: ${approval_id}`,
    );
  }

  if (
    approval.expires_at !== null &&
    Date.parse(approval.expires_at) <= Date.now()
  ) {
    throw new Error(
      `Execution approval expired: ${approval_id}`,
    );
  }

  const envelope = db
    .prepare(`
      SELECT package_id, package_version
      FROM governance_envelopes
      WHERE envelope_id = ?
      LIMIT 1
    `)
    .get(envelope_id) as
      | {
          package_id: string;
          package_version: number;
        }
      | undefined;

  if (!envelope) {
    throw new Error(`Governance envelope not found: ${envelope_id}`);
  }

  if (
    envelope.package_id !== approval.package_id ||
    envelope.package_version !== approval.package_version
  ) {
    throw new Error(
      "Persisted execution approval lineage no longer matches governance envelope.",
    );
  }

  return {
    ...approval,
    commit_authorized: approval.commit_authorized === 1,
    push_authorized: approval.push_authorized === 1,
    status: "approved",
  };
}
FILEEOF

cat > server/execution/compile-persisted-execution-approval.mjs << 'FILEEOF'
export function compilePersistedExecutionApproval(record = {}) {
  if (
    !record ||
    record.status !== "approved" ||
    typeof record.approval_id !== "string" ||
    record.approval_id.length === 0 ||
    typeof record.approved_by !== "string" ||
    record.approved_by.length === 0
  ) {
    throw new Error(
      "Persisted execution approval is invalid or not approved.",
    );
  }

  if (
    record.push_authorized === true &&
    record.commit_authorized !== true
  ) {
    throw new Error(
      "Persisted push approval requires commit authorization.",
    );
  }

  return {
    approval_id: record.approval_id,
    approved_by: record.approved_by,
    approval_scope: record.approval_scope,
    mutation_authorized: false,
    shell_execution_authorized: false,
    autonomous_execution_authorized: false,
    version_control_authorization: {
      commit_authorized: record.commit_authorized === true,
      push_authorized: record.push_authorized === true,
      remote: record.remote,
      branch: record.branch,
    },
    issued_at: record.issued_at,
    expires_at: record.expires_at ?? null,
    justification: record.justification ?? null,
    status: "approved",
  };
}
FILEEOF

cat > db/governance-execution-approval-persistence.test.ts << 'FILEEOF'
import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import {
  ensureGovernanceExecutionApprovalTable,
  loadGovernanceExecutionApproval,
  persistGovernanceExecutionApproval,
} from "./governance-execution-approval-persistence";

function fixture() {
  const db = new Database(":memory:");
  db.pragma("foreign_keys = ON");

  db.exec(`
    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version)
    );
  `);

  db.prepare(`
    INSERT INTO governance_packages (
      package_id,
      package_version
    ) VALUES (?, ?)
  `).run("pkg-1", 1);

  db.prepare(`
    INSERT INTO governance_envelopes (
      envelope_id,
      package_id,
      package_version
    ) VALUES (?, ?, ?)
  `).run("env-1", "pkg-1", 1);

  ensureGovernanceExecutionApprovalTable(db);
  return db;
}

test("persists and reads exact approved commit scope", () => {
  const db = fixture();

  const persisted = persistGovernanceExecutionApproval(db, {
    approval_id: "approval-1",
    envelope_id: "env-1",
    package_id: "pkg-1",
    package_version: 1,
    approved_by: "user",
    approval_scope: "governed_version_control_commit",
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch: "feature/test",
    issued_at: new Date(Date.now() - 1000).toISOString(),
  });

  assert.equal(persisted.status, "approved");
  assert.equal(persisted.commit_authorized, true);
  assert.equal(persisted.push_authorized, false);

  const loaded = loadGovernanceExecutionApproval(
    db,
    "approval-1",
    "env-1",
  );

  assert.equal(loaded.approval_id, "approval-1");
  assert.equal(loaded.envelope_id, "env-1");
});

test("rejects package lineage mismatch", () => {
  const db = fixture();

  assert.throws(() =>
    persistGovernanceExecutionApproval(db, {
      approval_id: "approval-2",
      envelope_id: "env-1",
      package_id: "pkg-other",
      package_version: 1,
      approved_by: "user",
      approval_scope: "governed_version_control_commit",
      commit_authorized: true,
      push_authorized: false,
      remote: "origin",
      branch: "feature/test",
      issued_at: new Date().toISOString(),
    }),
  );
});

test("rejects push without commit authority", () => {
  const db = fixture();

  assert.throws(() =>
    persistGovernanceExecutionApproval(db, {
      approval_id: "approval-3",
      envelope_id: "env-1",
      package_id: "pkg-1",
      package_version: 1,
      approved_by: "user",
      approval_scope: "governed_version_control_push",
      commit_authorized: false,
      push_authorized: true,
      remote: "origin",
      branch: "feature/test",
      issued_at: new Date().toISOString(),
    }),
  );
});

test("fails closed on envelope replay", () => {
  const db = fixture();

  persistGovernanceExecutionApproval(db, {
    approval_id: "approval-4",
    envelope_id: "env-1",
    package_id: "pkg-1",
    package_version: 1,
    approved_by: "user",
    approval_scope: "governed_version_control_commit",
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch: "feature/test",
    issued_at: new Date().toISOString(),
  });

  assert.throws(() =>
    loadGovernanceExecutionApproval(
      db,
      "approval-4",
      "env-other",
    ),
  );
});
FILEEOF

cat > server/execution/compile-persisted-execution-approval.test.mjs << 'FILEEOF'
import test from "node:test";
import assert from "node:assert/strict";

import {
  compilePersistedExecutionApproval,
} from "./compile-persisted-execution-approval.mjs";

test("compiles persisted approval into existing gate shape", () => {
  const compiled = compilePersistedExecutionApproval({
    approval_id: "approval-1",
    approved_by: "user",
    approval_scope: "governed_version_control_commit",
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch: "feature/test",
    issued_at: new Date().toISOString(),
    expires_at: null,
    justification: "explicit user approval",
    status: "approved",
  });

  assert.deepEqual(
    compiled.version_control_authorization,
    {
      commit_authorized: true,
      push_authorized: false,
      remote: "origin",
      branch: "feature/test",
    },
  );

  assert.equal(compiled.mutation_authorized, false);
  assert.equal(compiled.shell_execution_authorized, false);
  assert.equal(compiled.autonomous_execution_authorized, false);
});

test("rejects invalid approval state", () => {
  assert.throws(() =>
    compilePersistedExecutionApproval({
      approval_id: "approval-2",
      approved_by: "user",
      status: "approval_required",
    }),
  );
});

test("rejects push without commit", () => {
  assert.throws(() =>
    compilePersistedExecutionApproval({
      approval_id: "approval-3",
      approved_by: "user",
      approval_scope: "governed_version_control_push",
      commit_authorized: false,
      push_authorized: true,
      remote: "origin",
      branch: "feature/test",
      issued_at: new Date().toISOString(),
      status: "approved",
    }),
  );
});
FILEEOF

echo "=== VERIFY AUTHORIZED IMPLEMENTATION ==="
npx tsx --test db/governance-execution-approval-persistence.test.ts
node --test server/execution/compile-persisted-execution-approval.test.mjs
npx tsc --noEmit

echo
echo "=== VERIFY EXCLUDED SURFACES UNCHANGED ==="
git diff --exit-code HEAD -- \
  routes/cade.ts \
  server/routes/cade.ts \
  server/cade/cade-executor.ts \
  server/execution/cade-governed-commit-adapter.ts \
  server/execution/cade-governed-push-adapter.ts \
  server/index.ts

echo
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "APPROVAL_PERSISTENCE_IMPLEMENTED=YES"
echo "USER_OWNED_APPROVAL_WRITE_IMPLEMENTED=YES"
echo "FAIL_CLOSED_READER_IMPLEMENTED=YES"
echo "APPROVAL_COMPILER_IMPLEMENTED=YES"
echo "TARGETED_TESTS_IMPLEMENTED=YES"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo "ROUTE_MOUNT_CHANGED=NO"
echo "GIT_EFFECT_CHANGED=NO"
echo "NEXT_ACTION=VERIFY_AND_CLASSIFY_APPROVAL_TRANSITION_IMPLEMENTATION"
echo
git status --short

git add \
  db/governance-execution-approval-persistence.ts \
  db/governance-execution-approval-persistence.test.ts \
  server/execution/compile-persisted-execution-approval.mjs \
  server/execution/compile-persisted-execution-approval.test.mjs \
  scripts/implement-corridor-6-approval-transition-unit.sh

git commit -m "Implement Corridor 6 execution approval transition"
git push
