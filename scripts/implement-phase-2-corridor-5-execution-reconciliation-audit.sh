#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="18f147b3931bf103b9216546fb96d2dd8f2ae732"
EXPECTED_BRANCH="feature/support-source-references-runtime"
RECOVERY_POINT="DR_20260828_155621"

test "$(git rev-parse HEAD)" = "${EXPECTED_HEAD}"
test "$(git branch --show-current)" = "${EXPECTED_BRANCH}"

for path in \
  db/governance-execution-reconciliation-persistence.ts \
  db/governance-execution-reconciliation-persistence.test.ts
do
  if [[ -e "${path}" ]]; then
    echo "REFUSING_TO_OVERWRITE_EXISTING_TARGET=${path}"
    exit 1
  fi
done

for path in \
  server/routes/governance-execution-route.ts \
  server/routes/governance-execution-route.test.ts
do
  if ! git diff --quiet -- "${path}" || ! git diff --cached --quiet -- "${path}"; then
    echo "REFUSING_TO_OVERWRITE_DIRTY_TARGET=${path}"
    exit 1
  fi
done

cat > db/governance-execution-reconciliation-persistence.ts << 'FILE_EOF'
import type { Database } from "better-sqlite3";

export const GOVERNANCE_EXECUTION_RECONCILIATION_STAGES = [
  "EXECUTION_STARTED",
  "EXECUTION_NO_EFFECT_COMPLETED",
  "COMMIT_CONFIRMED",
  "PUSH_CONFIRMED",
  "EXECUTION_FAILED_CLOSED",
] as const;

export type GovernanceExecutionReconciliationStage =
  (typeof GOVERNANCE_EXECUTION_RECONCILIATION_STAGES)[number];

export type GovernanceExecutionEffectStatus =
  | "none"
  | "confirmed"
  | "unknown";

export type PersistGovernanceExecutionReconciliationEntryInput = {
  execution_id: string;
  stage: GovernanceExecutionReconciliationStage;
  project_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  envelope_gate_id: string;
  approval_id: string;
  envelope_id: string;
  repo_path: string;
  expected_head: string;
  branch: string;
  allowed_paths: string[];
  forbidden_paths: string[];
  scope_constraints: string;
  commit_requested: boolean;
  push_requested: boolean;
  local_effect_status: GovernanceExecutionEffectStatus;
  remote_effect_status: GovernanceExecutionEffectStatus;
  evidence?: Record<string, unknown> | null;
  persisted_at?: string;
};

export type PersistedGovernanceExecutionReconciliationEntry = {
  entry_id: number;
  execution_id: string;
  entry_sequence: number;
  stage: GovernanceExecutionReconciliationStage;
  project_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  envelope_gate_id: string;
  approval_id: string;
  envelope_id: string;
  repo_path: string;
  expected_head: string;
  branch: string;
  allowed_paths: string[];
  forbidden_paths: string[];
  scope_constraints: string;
  commit_requested: boolean;
  push_requested: boolean;
  local_effect_status: GovernanceExecutionEffectStatus;
  remote_effect_status: GovernanceExecutionEffectStatus;
  evidence: Record<string, unknown> | null;
  persisted_at: string;
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(
      `Missing required execution reconciliation field: ${field}`,
    );
  }
  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required execution reconciliation field: package_version",
    );
  }
  return Number(value);
}

function requireExpectedHead(value: unknown): string {
  const result = requireText(value, "expected_head");
  if (!/^[0-9a-f]{40}$/i.test(result)) {
    throw new Error(
      "Execution reconciliation expected_head must be a 40-character SHA.",
    );
  }
  return result;
}

function requireBoolean(value: unknown, field: string): boolean {
  if (typeof value !== "boolean") {
    throw new Error(
      `Execution reconciliation ${field} must be boolean.`,
    );
  }
  return value;
}

function requireStage(
  value: unknown,
): GovernanceExecutionReconciliationStage {
  if (
    typeof value !== "string" ||
    !GOVERNANCE_EXECUTION_RECONCILIATION_STAGES.includes(
      value as GovernanceExecutionReconciliationStage,
    )
  ) {
    throw new Error("Execution reconciliation stage is invalid.");
  }
  return value as GovernanceExecutionReconciliationStage;
}

function requireEffectStatus(
  value: unknown,
  field: string,
): GovernanceExecutionEffectStatus {
  if (
    value !== "none" &&
    value !== "confirmed" &&
    value !== "unknown"
  ) {
    throw new Error(
      `Execution reconciliation ${field} is invalid.`,
    );
  }
  return value;
}

function requirePathList(
  value: unknown,
  field: string,
  allowEmpty: boolean,
): string[] {
  if (!Array.isArray(value)) {
    throw new Error(
      `Execution reconciliation ${field} must be an array.`,
    );
  }

  const values = value.map((entry) => {
    if (typeof entry !== "string" || entry.trim().length === 0) {
      throw new Error(
        `Execution reconciliation ${field} contains an invalid path.`,
      );
    }
    return entry.trim();
  });

  if (!allowEmpty && values.length === 0) {
    throw new Error(
      `Execution reconciliation ${field} must not be empty.`,
    );
  }

  if (new Set(values).size !== values.length) {
    throw new Error(
      `Execution reconciliation ${field} must not contain duplicates.`,
    );
  }

  return values;
}

function parsePathList(
  value: string,
  field: string,
  allowEmpty: boolean,
): string[] {
  let parsed: unknown;
  try {
    parsed = JSON.parse(value);
  } catch {
    throw new Error(
      `Persisted execution reconciliation ${field} is invalid JSON.`,
    );
  }
  return requirePathList(parsed, field, allowEmpty);
}

function normalizeEvidence(
  value: unknown,
): Record<string, unknown> | null {
  if (value === undefined || value === null) {
    return null;
  }
  if (typeof value !== "object" || Array.isArray(value)) {
    throw new Error(
      "Execution reconciliation evidence must be an object.",
    );
  }
  return value as Record<string, unknown>;
}

function validateStageSemantics(input: {
  stage: GovernanceExecutionReconciliationStage;
  commit_requested: boolean;
  push_requested: boolean;
  local_effect_status: GovernanceExecutionEffectStatus;
  remote_effect_status: GovernanceExecutionEffectStatus;
}) {
  if (input.push_requested && !input.commit_requested) {
    throw new Error(
      "Execution reconciliation refuses push without commit.",
    );
  }

  if (
    input.stage === "EXECUTION_STARTED" &&
    (
      input.local_effect_status !== "none" ||
      input.remote_effect_status !== "none"
    )
  ) {
    throw new Error(
      "EXECUTION_STARTED cannot claim effects.",
    );
  }

  if (
    input.stage === "EXECUTION_NO_EFFECT_COMPLETED" &&
    (
      input.commit_requested ||
      input.push_requested ||
      input.local_effect_status !== "none" ||
      input.remote_effect_status !== "none"
    )
  ) {
    throw new Error(
      "EXECUTION_NO_EFFECT_COMPLETED requires no requested effects.",
    );
  }

  if (
    input.stage === "COMMIT_CONFIRMED" &&
    (
      !input.commit_requested ||
      input.local_effect_status !== "confirmed" ||
      input.remote_effect_status !== "none"
    )
  ) {
    throw new Error(
      "COMMIT_CONFIRMED requires confirmed local effect only.",
    );
  }

  if (
    input.stage === "PUSH_CONFIRMED" &&
    (
      !input.commit_requested ||
      !input.push_requested ||
      input.local_effect_status !== "confirmed" ||
      input.remote_effect_status !== "confirmed"
    )
  ) {
    throw new Error(
      "PUSH_CONFIRMED requires confirmed local and remote effects.",
    );
  }
}

export function ensureGovernanceExecutionReconciliationTable(
  db: Database,
): void {
  db.exec(`
    CREATE TABLE IF NOT EXISTS governance_execution_reconciliation_entries (
      entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
      execution_id TEXT NOT NULL,
      entry_sequence INTEGER NOT NULL,
      stage TEXT NOT NULL,
      project_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL,
      approval_id TEXT NOT NULL,
      envelope_id TEXT NOT NULL,
      repo_path TEXT NOT NULL,
      expected_head TEXT NOT NULL,
      branch TEXT NOT NULL,
      allowed_paths TEXT NOT NULL,
      forbidden_paths TEXT NOT NULL,
      scope_constraints TEXT NOT NULL,
      commit_requested INTEGER NOT NULL,
      push_requested INTEGER NOT NULL,
      local_effect_status TEXT NOT NULL,
      remote_effect_status TEXT NOT NULL,
      evidence_json TEXT,
      persisted_at TEXT NOT NULL,
      UNIQUE (execution_id, entry_sequence),
      UNIQUE (execution_id, stage),
      FOREIGN KEY (approval_id)
        REFERENCES governance_execution_approvals(approval_id),
      FOREIGN KEY (envelope_id)
        REFERENCES governance_envelopes(envelope_id)
    );

    CREATE INDEX IF NOT EXISTS
      idx_governance_execution_reconciliation_execution
      ON governance_execution_reconciliation_entries (
        execution_id,
        entry_sequence
      );
  `);
}

function assertAuthoritativeScope(
  db: Database,
  input: PersistGovernanceExecutionReconciliationEntryInput,
): void {
  const rows = db.prepare(`
    SELECT
      a.status,
      s.repo_path,
      s.expected_head,
      s.branch,
      s.allowed_paths,
      s.forbidden_paths,
      s.scope_constraints
    FROM governance_execution_approvals a
    INNER JOIN governance_execution_scopes s
      ON s.approval_id = a.approval_id
     AND s.envelope_id = a.envelope_id
     AND s.package_id = a.package_id
     AND s.package_version = a.package_version
    WHERE a.approval_id = ?
      AND a.envelope_id = ?
      AND a.package_id = ?
      AND a.package_version = ?
    LIMIT 2
  `).all(
    input.approval_id,
    input.envelope_id,
    input.package_id,
    input.package_version,
  ) as Array<{
    status: string;
    repo_path: string;
    expected_head: string;
    branch: string;
    allowed_paths: string;
    forbidden_paths: string;
    scope_constraints: string;
  }>;

  if (rows.length !== 1 || rows[0].status !== "approved") {
    throw new Error(
      "Execution reconciliation approval/scope lineage not found or approved.",
    );
  }

  const row = rows[0];
  const allowed = parsePathList(
    row.allowed_paths,
    "allowed_paths",
    false,
  );
  const forbidden = parsePathList(
    row.forbidden_paths,
    "forbidden_paths",
    true,
  );

  if (
    row.repo_path !== input.repo_path ||
    row.expected_head !== input.expected_head ||
    row.branch !== input.branch ||
    row.scope_constraints !== input.scope_constraints ||
    JSON.stringify(allowed) !== JSON.stringify(input.allowed_paths) ||
    JSON.stringify(forbidden) !== JSON.stringify(input.forbidden_paths)
  ) {
    throw new Error(
      "Execution reconciliation scope snapshot does not match durable execution scope.",
    );
  }
}

export function listGovernanceExecutionReconciliationEntries(
  db: Database,
  executionId: string,
): PersistedGovernanceExecutionReconciliationEntry[] {
  ensureGovernanceExecutionReconciliationTable(db);

  const rows = db.prepare(`
    SELECT *
    FROM governance_execution_reconciliation_entries
    WHERE execution_id = ?
    ORDER BY entry_sequence ASC
  `).all(
    requireText(executionId, "execution_id"),
  ) as any[];

  return rows.map((row) => ({
    entry_id: row.entry_id,
    execution_id: row.execution_id,
    entry_sequence: row.entry_sequence,
    stage: requireStage(row.stage),
    project_id: row.project_id,
    package_id: row.package_id,
    package_version: row.package_version,
    delegation_id: row.delegation_id,
    validation_result_id: row.validation_result_id,
    envelope_gate_id: row.envelope_gate_id,
    approval_id: row.approval_id,
    envelope_id: row.envelope_id,
    repo_path: row.repo_path,
    expected_head: row.expected_head,
    branch: row.branch,
    allowed_paths: parsePathList(
      row.allowed_paths,
      "allowed_paths",
      false,
    ),
    forbidden_paths: parsePathList(
      row.forbidden_paths,
      "forbidden_paths",
      true,
    ),
    scope_constraints: row.scope_constraints,
    commit_requested: row.commit_requested === 1,
    push_requested: row.push_requested === 1,
    local_effect_status: requireEffectStatus(
      row.local_effect_status,
      "local_effect_status",
    ),
    remote_effect_status: requireEffectStatus(
      row.remote_effect_status,
      "remote_effect_status",
    ),
    evidence:
      row.evidence_json === null
        ? null
        : normalizeEvidence(
            JSON.parse(row.evidence_json),
          ),
    persisted_at: row.persisted_at,
  }));
}

export function persistGovernanceExecutionReconciliationEntry(
  db: Database,
  raw: PersistGovernanceExecutionReconciliationEntryInput,
): PersistedGovernanceExecutionReconciliationEntry {
  ensureGovernanceExecutionReconciliationTable(db);

  const input = {
    ...raw,
    execution_id: requireText(raw.execution_id, "execution_id"),
    stage: requireStage(raw.stage),
    project_id: requireText(raw.project_id, "project_id"),
    package_id: requireText(raw.package_id, "package_id"),
    package_version: requirePackageVersion(raw.package_version),
    delegation_id: requireText(raw.delegation_id, "delegation_id"),
    validation_result_id: requireText(
      raw.validation_result_id,
      "validation_result_id",
    ),
    envelope_gate_id: requireText(
      raw.envelope_gate_id,
      "envelope_gate_id",
    ),
    approval_id: requireText(raw.approval_id, "approval_id"),
    envelope_id: requireText(raw.envelope_id, "envelope_id"),
    repo_path: requireText(raw.repo_path, "repo_path"),
    expected_head: requireExpectedHead(raw.expected_head),
    branch: requireText(raw.branch, "branch"),
    allowed_paths: requirePathList(
      raw.allowed_paths,
      "allowed_paths",
      false,
    ),
    forbidden_paths: requirePathList(
      raw.forbidden_paths,
      "forbidden_paths",
      true,
    ),
    scope_constraints: requireText(
      raw.scope_constraints,
      "scope_constraints",
    ),
    commit_requested: requireBoolean(
      raw.commit_requested,
      "commit_requested",
    ),
    push_requested: requireBoolean(
      raw.push_requested,
      "push_requested",
    ),
    local_effect_status: requireEffectStatus(
      raw.local_effect_status,
      "local_effect_status",
    ),
    remote_effect_status: requireEffectStatus(
      raw.remote_effect_status,
      "remote_effect_status",
    ),
    evidence: normalizeEvidence(raw.evidence),
    persisted_at:
      raw.persisted_at ?? new Date().toISOString(),
  };

  validateStageSemantics(input);
  assertAuthoritativeScope(db, input);

  const transaction = db.transaction(() => {
    const existing =
      listGovernanceExecutionReconciliationEntries(
        db,
        input.execution_id,
      );

    if (existing.some((entry) => entry.stage === input.stage)) {
      throw new Error(
        `Execution reconciliation stage already exists: ${input.execution_id} / ${input.stage}`,
      );
    }

    if (
      existing.length === 0 &&
      input.stage !== "EXECUTION_STARTED"
    ) {
      throw new Error(
        "Execution reconciliation lineage must begin with EXECUTION_STARTED.",
      );
    }

    if (existing.length > 0) {
      const first = existing[0];

      if (
        first.commit_requested !== input.commit_requested ||
        first.push_requested !== input.push_requested
      ) {
        throw new Error(
          "Execution reconciliation request contract changed within lineage.",
        );
      }

      const terminal = existing.some(
        (entry) =>
          entry.stage === "EXECUTION_NO_EFFECT_COMPLETED" ||
          entry.stage === "PUSH_CONFIRMED" ||
          entry.stage === "EXECUTION_FAILED_CLOSED" ||
          (
            entry.stage === "COMMIT_CONFIRMED" &&
            !entry.push_requested
          ),
      );

      if (terminal) {
        throw new Error(
          `Execution reconciliation lineage is already terminal: ${input.execution_id}`,
        );
      }

      if (
        input.stage === "PUSH_CONFIRMED" &&
        !existing.some(
          (entry) => entry.stage === "COMMIT_CONFIRMED",
        )
      ) {
        throw new Error(
          "PUSH_CONFIRMED requires prior COMMIT_CONFIRMED.",
        );
      }
    }

    const entrySequence =
      existing.length === 0
        ? 1
        : existing[existing.length - 1].entry_sequence + 1;

    const result = db.prepare(`
      INSERT INTO governance_execution_reconciliation_entries (
        execution_id,
        entry_sequence,
        stage,
        project_id,
        package_id,
        package_version,
        delegation_id,
        validation_result_id,
        envelope_gate_id,
        approval_id,
        envelope_id,
        repo_path,
        expected_head,
        branch,
        allowed_paths,
        forbidden_paths,
        scope_constraints,
        commit_requested,
        push_requested,
        local_effect_status,
        remote_effect_status,
        evidence_json,
        persisted_at
      ) VALUES (
        @execution_id,
        @entry_sequence,
        @stage,
        @project_id,
        @package_id,
        @package_version,
        @delegation_id,
        @validation_result_id,
        @envelope_gate_id,
        @approval_id,
        @envelope_id,
        @repo_path,
        @expected_head,
        @branch,
        @allowed_paths,
        @forbidden_paths,
        @scope_constraints,
        @commit_requested,
        @push_requested,
        @local_effect_status,
        @remote_effect_status,
        @evidence_json,
        @persisted_at
      )
    `).run({
      execution_id: input.execution_id,
      entry_sequence: entrySequence,
      stage: input.stage,
      project_id: input.project_id,
      package_id: input.package_id,
      package_version: input.package_version,
      delegation_id: input.delegation_id,
      validation_result_id: input.validation_result_id,
      envelope_gate_id: input.envelope_gate_id,
      approval_id: input.approval_id,
      envelope_id: input.envelope_id,
      repo_path: input.repo_path,
      expected_head: input.expected_head,
      branch: input.branch,
      allowed_paths: JSON.stringify(input.allowed_paths),
      forbidden_paths: JSON.stringify(input.forbidden_paths),
      scope_constraints: input.scope_constraints,
      commit_requested: input.commit_requested ? 1 : 0,
      push_requested: input.push_requested ? 1 : 0,
      local_effect_status: input.local_effect_status,
      remote_effect_status: input.remote_effect_status,
      evidence_json:
        input.evidence === null
          ? null
          : JSON.stringify(input.evidence),
      persisted_at: input.persisted_at,
    });

    const entries =
      listGovernanceExecutionReconciliationEntries(
        db,
        input.execution_id,
      );

    const persisted = entries.find(
      (entry) => entry.entry_id === Number(result.lastInsertRowid),
    );

    if (!persisted) {
      throw new Error(
        "Execution reconciliation entry not readable after persistence.",
      );
    }

    return persisted;
  });

  return transaction();
}
FILE_EOF

cat > db/governance-execution-reconciliation-persistence.test.ts << 'FILE_EOF'
import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

import {
  listGovernanceExecutionReconciliationEntries,
  persistGovernanceExecutionReconciliationEntry,
} from "./governance-execution-reconciliation-persistence";

const HEAD =
  "1111111111111111111111111111111111111111";

function createDb() {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE governance_execution_approvals (
      approval_id TEXT PRIMARY KEY,
      envelope_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      status TEXT NOT NULL
    );

    CREATE TABLE governance_execution_scopes (
      approval_id TEXT PRIMARY KEY,
      envelope_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      repo_path TEXT NOT NULL,
      expected_head TEXT NOT NULL,
      branch TEXT NOT NULL,
      allowed_paths TEXT NOT NULL,
      forbidden_paths TEXT NOT NULL,
      scope_constraints TEXT NOT NULL
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY
    );

    INSERT INTO governance_envelopes VALUES ('e1');

    INSERT INTO governance_execution_approvals
    VALUES ('a1', 'e1', 'p1', 1, 'approved');

    INSERT INTO governance_execution_scopes
    VALUES (
      'a1',
      'e1',
      'p1',
      1,
      '/tmp/repo',
      '${HEAD}',
      'feature/test',
      '["server/example.ts"]',
      '[".env"]',
      'bounded'
    );
  `);

  return db;
}

function base(overrides: Record<string, unknown> = {}) {
  return {
    execution_id: "x1",
    stage: "EXECUTION_STARTED" as const,
    project_id: "hq",
    package_id: "p1",
    package_version: 1,
    delegation_id: "d1",
    validation_result_id: "v1",
    envelope_gate_id: "g1",
    approval_id: "a1",
    envelope_id: "e1",
    repo_path: "/tmp/repo",
    expected_head: HEAD,
    branch: "feature/test",
    allowed_paths: ["server/example.ts"],
    forbidden_paths: [".env"],
    scope_constraints: "bounded",
    commit_requested: true,
    push_requested: true,
    local_effect_status: "none" as const,
    remote_effect_status: "none" as const,
    evidence: null,
    ...overrides,
  };
}

test("persists ordered immutable stages", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base(),
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "COMMIT_CONFIRMED",
      local_effect_status: "confirmed",
    }) as any,
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "PUSH_CONFIRMED",
      local_effect_status: "confirmed",
      remote_effect_status: "confirmed",
    }) as any,
  );

  assert.deepEqual(
    listGovernanceExecutionReconciliationEntries(
      db,
      "x1",
    ).map((entry) => entry.stage),
    [
      "EXECUTION_STARTED",
      "COMMIT_CONFIRMED",
      "PUSH_CONFIRMED",
    ],
  );
});

test("rejects duplicate stages", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base(),
  );

  assert.throws(
    () =>
      persistGovernanceExecutionReconciliationEntry(
        db,
        base(),
      ),
    /stage already exists/,
  );
});

test("rejects scope drift", () => {
  const db = createDb();

  assert.throws(
    () =>
      persistGovernanceExecutionReconciliationEntry(
        db,
        base({
          allowed_paths: ["server/other.ts"],
        }) as any,
      ),
    /scope snapshot does not match/,
  );
});

test("preserves unknown effect state on failure", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base(),
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "EXECUTION_FAILED_CLOSED",
      local_effect_status: "unknown",
      remote_effect_status: "none",
    }) as any,
  );

  const entries =
    listGovernanceExecutionReconciliationEntries(
      db,
      "x1",
    );

  assert.equal(
    entries[1].local_effect_status,
    "unknown",
  );
});
FILE_EOF

python3 << 'PY'
from pathlib import Path

route = Path("server/routes/governance-execution-route.ts")
text = route.read_text()

anchor = '''import {
  executeProductionExecutionEntryPoint,
  type ProductionExecutionRequest,
} from "../execution/production-execution-entry-point.js";
'''
replacement = anchor + '''import {
  persistGovernanceExecutionReconciliationEntry,
  type GovernanceExecutionEffectStatus,
  type GovernanceExecutionReconciliationStage,
} from "../../db/governance-execution-reconciliation-persistence.js";
'''

if anchor not in text:
    raise SystemExit("ROUTE_IMPORT_ANCHOR_NOT_FOUND")
text = text.replace(anchor, replacement, 1)

anchor = '''  compile_approval?: typeof compilePersistedExecutionApproval;
  execute_execution?: ExecutionEntryPoint;
};
'''
replacement = '''  compile_approval?: typeof compilePersistedExecutionApproval;
  execute_execution?: ExecutionEntryPoint;
  persist_reconciliation_entry?: typeof persistGovernanceExecutionReconciliationEntry;
};
'''

if anchor not in text:
    raise SystemExit("ROUTE_DEPENDENCY_ANCHOR_NOT_FOUND")
text = text.replace(anchor, replacement, 1)

anchor = '''    const execution = executeExecution(
      request,
      {
        evaluateApproval:
          dependencies.evaluate_approval,
        executeCommit:
          dependencies.execute_commit as any,
        executePush:
          dependencies.execute_push as any,
      },
    );

    return {
      ok: true,
      route: "governance_execution_route",
      execution,
      route_mounted: false,
      production_reachability_authorized: false,
      production_approval_gate_bound: false,
      new_authority_introduced: false,
    };
'''

replacement = '''    const persistReconciliation =
      dependencies.persist_reconciliation_entry ??
      persistGovernanceExecutionReconciliationEntry;

    const reconciliationBase = {
      execution_id: executionId,
      project_id:
        governanceChain.delegation.project_id,
      package_id: identity.package_id,
      package_version: identity.package_version,
      delegation_id: identity.delegation_id,
      validation_result_id:
        identity.validation_result_id,
      envelope_gate_id:
        identity.envelope_gate_id,
      approval_id: approvalId,
      envelope_id: envelopeId,
      repo_path: scope.repo_path,
      expected_head: scope.expected_head,
      branch: scope.branch,
      allowed_paths: scope.allowed_paths,
      forbidden_paths: scope.forbidden_paths,
      scope_constraints: scope.scope_constraints,
      commit_requested: commitRequested,
      push_requested: pushRequested,
    };

    const appendReconciliation = (
      stage: GovernanceExecutionReconciliationStage,
      localEffectStatus: GovernanceExecutionEffectStatus,
      remoteEffectStatus: GovernanceExecutionEffectStatus,
      evidence: Record<string, unknown> | null = null,
    ) =>
      persistReconciliation(
        dependencies.db,
        {
          ...reconciliationBase,
          stage,
          local_effect_status: localEffectStatus,
          remote_effect_status: remoteEffectStatus,
          evidence,
        },
      );

    let commitAttempted = false;
    let commitConfirmed = false;
    let pushAttempted = false;
    let pushConfirmed = false;

    appendReconciliation(
      "EXECUTION_STARTED",
      "none",
      "none",
    );

    try {
      const execution = executeExecution(
        request,
        {
          evaluateApproval:
            dependencies.evaluate_approval,
          executeCommit: ((...args: any[]) => {
            commitAttempted = true;
            const result =
              dependencies.execute_commit(...args);

            appendReconciliation(
              "COMMIT_CONFIRMED",
              "confirmed",
              "none",
              {
                pre_head: result.preHead,
                post_head: result.postHead,
                branch: result.branch,
                committed_files:
                  result.committedFiles,
                commit_message:
                  result.commitMessage,
              },
            );

            commitConfirmed = true;
            return result;
          }) as any,
          executePush: ((...args: any[]) => {
            pushAttempted = true;
            const result =
              dependencies.execute_push(...args);

            appendReconciliation(
              "PUSH_CONFIRMED",
              "confirmed",
              "confirmed",
              {
                local_head: result.localHead,
                branch: result.branch,
                remote: result.remote,
                remote_url: result.remoteUrl,
                pre_remote_head:
                  result.preRemoteHead,
                post_remote_head:
                  result.postRemoteHead,
                force_effect:
                  result.forceEffect,
              },
            );

            pushConfirmed = true;
            return result;
          }) as any,
        },
      );

      if (
        execution.commit_requested === false &&
        execution.push_requested === false
      ) {
        appendReconciliation(
          "EXECUTION_NO_EFFECT_COMPLETED",
          "none",
          "none",
        );
      }

      return {
        ok: true,
        route: "governance_execution_route",
        execution,
        route_mounted: false,
        production_reachability_authorized: false,
        production_approval_gate_bound: false,
        new_authority_introduced: false,
      };
    } catch (error) {
      appendReconciliation(
        "EXECUTION_FAILED_CLOSED",
        commitConfirmed
          ? "confirmed"
          : commitAttempted
            ? "unknown"
            : "none",
        pushConfirmed
          ? "confirmed"
          : pushAttempted
            ? "unknown"
            : "none",
        {
          error_message:
            error instanceof Error
              ? error.message
              : String(error),
          error_code:
            error instanceof Error &&
            "code" in error
              ? String(
                  (
                    error as Error & {
                      code?: unknown;
                    }
                  ).code ?? "",
                )
              : null,
          last_confirmed_stage:
            pushConfirmed
              ? "PUSH_CONFIRMED"
              : commitConfirmed
                ? "COMMIT_CONFIRMED"
                : "EXECUTION_STARTED",
        },
      );

      throw error;
    }
'''

if anchor not in text:
    raise SystemExit("ROUTE_EXECUTION_ANCHOR_NOT_FOUND")

text = text.replace(anchor, replacement, 1)
route.write_text(text)
PY

python3 << 'PY'
from pathlib import Path

path = Path("server/routes/governance-execution-route.test.ts")
text = path.read_text()

anchor = '''    execute_push: (() => {
      assert.fail("real push effect must not run");
    }) as any,
    ...overrides,
'''

replacement = '''    execute_push: (() => {
      assert.fail("real push effect must not run");
    }) as any,
    persist_reconciliation_entry: (() => ({
      entry_id: 1,
    })) as any,
    ...overrides,
'''

if anchor not in text:
    raise SystemExit("ROUTE_TEST_DEPENDENCY_ANCHOR_NOT_FOUND")

text = text.replace(anchor, replacement, 1)

text += r'''

test(
  "records reconciliation for no-effect execution",
  () => {
    const stages: string[] = [];

    const result =
      handleGovernanceExecutionRouteRequest(
        {
          approval_id: "a1",
          envelope_id: "e1",
          execution_id: "x-reconcile-no-effect",
          commit_requested: false,
          push_requested: false,
        },
        deps({
          persist_reconciliation_entry:
            ((_db: unknown, input: any) => {
              stages.push(input.stage);
              return { entry_id: stages.length };
            }) as any,
        }),
      );

    assert.equal(result.ok, true);
    assert.deepEqual(
      stages,
      [
        "EXECUTION_STARTED",
        "EXECUTION_NO_EFFECT_COMPLETED",
      ],
    );
  },
);
'''

path.write_text(text)
PY

echo "=== CORRIDOR 5 VERIFICATION ==="
git diff --check

node --import tsx --test \
  db/governance-execution-reconciliation-persistence.test.ts \
  server/routes/governance-execution-route.test.ts \
  server/execution/production-execution-entry-point.test.ts

npx tsc --noEmit

if [[ -f scripts/check-semantic-drift.mjs ]]; then
  node scripts/check-semantic-drift.mjs
fi

echo "=== CORRIDOR 5 VERIFIED IMPLEMENTATION ==="
echo "RECONCILIATION_AUTHORITY=DEDICATED_DURABLE_DATABASE_LEDGER"
echo "RECONCILIATION_MODEL=APPEND_ONLY_IMMUTABLE_STAGE_ENTRIES"
echo "PARTIAL_EFFECT_RECONCILIATION=IMPLEMENTED"
echo "EXISTING_COMMIT_GUARDS=UNCHANGED"
echo "EXISTING_PUSH_GUARDS=UNCHANGED"
echo "NEW_PARALLEL_ORCHESTRATOR=NO"
echo "NEW_EXECUTION_AUTHORITY=NO"
echo "PRODUCTION_GIT_EFFECT_EXECUTED=NO"
echo "PRODUCTION_PUSH_EFFECT_EXECUTED=NO"
echo "CORRIDOR_6_STATUS=NOT_ACTIVE"
