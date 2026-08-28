import type { Database } from "better-sqlite3";

import {
  loadGovernanceExecutionApproval,
} from "./governance-execution-approval-persistence";

export type CreateGovernanceExecutionScopeInput = {
  approval_id: string;
  envelope_id: string;
  package_id: string;
  package_version: number;
  repo_path: string;
  expected_head: string;
  branch: string;
  allowed_paths: string[];
  forbidden_paths: string[];
  scope_constraints: string;
};

export type PersistedGovernanceExecutionScope = {
  approval_id: string;
  envelope_id: string;
  package_id: string;
  package_version: number;
  repo_path: string;
  expected_head: string;
  branch: string;
  allowed_paths: string[];
  forbidden_paths: string[];
  scope_constraints: string;
  created_at: string;
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required execution scope field: ${field}`);
  }

  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required execution scope field: package_version",
    );
  }

  return Number(value);
}

function requireExpectedHead(value: unknown): string {
  const expectedHead = requireText(value, "expected_head");

  if (!/^[0-9a-f]{40}$/i.test(expectedHead)) {
    throw new Error(
      "Execution scope expected_head must be a 40-character git commit SHA.",
    );
  }

  return expectedHead;
}

function requirePathList(
  value: unknown,
  field: string,
  { allowEmpty }: { allowEmpty: boolean },
): string[] {
  if (!Array.isArray(value)) {
    throw new Error(`Execution scope ${field} must be an array.`);
  }

  const normalized = value.map((entry) => {
    if (typeof entry !== "string" || entry.trim().length === 0) {
      throw new Error(
        `Execution scope ${field} must contain only non-empty paths.`,
      );
    }

    return entry.trim();
  });

  if (!allowEmpty && normalized.length === 0) {
    throw new Error(
      `Execution scope ${field} must contain at least one path.`,
    );
  }

  if (new Set(normalized).size !== normalized.length) {
    throw new Error(`Execution scope ${field} must not contain duplicates.`);
  }

  return normalized;
}

function parsePersistedPathList(
  value: string,
  field: string,
  { allowEmpty }: { allowEmpty: boolean },
): string[] {
  let parsed: unknown;

  try {
    parsed = JSON.parse(value);
  } catch {
    throw new Error(`Persisted execution scope ${field} is invalid JSON.`);
  }

  return requirePathList(parsed, field, { allowEmpty });
}

export function ensureGovernanceExecutionScopeTable(
  db: Database,
): void {
  db.exec(`
    CREATE TABLE IF NOT EXISTS governance_execution_scopes (
      approval_id TEXT PRIMARY KEY,
      envelope_id TEXT NOT NULL UNIQUE,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      repo_path TEXT NOT NULL,
      expected_head TEXT NOT NULL,
      branch TEXT NOT NULL,
      allowed_paths TEXT NOT NULL,
      forbidden_paths TEXT NOT NULL,
      scope_constraints TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (approval_id)
        REFERENCES governance_execution_approvals(approval_id),
      FOREIGN KEY (envelope_id)
        REFERENCES governance_envelopes(envelope_id),
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version)
    );

    CREATE UNIQUE INDEX IF NOT EXISTS
      idx_governance_execution_scopes_approval_envelope
      ON governance_execution_scopes (
        approval_id,
        envelope_id
      );
  `);
}

export function persistGovernanceExecutionScope(
  db: Database,
  input: CreateGovernanceExecutionScopeInput,
): PersistedGovernanceExecutionScope {
  ensureGovernanceExecutionScopeTable(db);

  const approval_id = requireText(input.approval_id, "approval_id");
  const envelope_id = requireText(input.envelope_id, "envelope_id");
  const package_id = requireText(input.package_id, "package_id");
  const package_version = requirePackageVersion(input.package_version);
  const repo_path = requireText(input.repo_path, "repo_path");
  const expected_head = requireExpectedHead(input.expected_head);
  const branch = requireText(input.branch, "branch");
  const allowed_paths = requirePathList(
    input.allowed_paths,
    "allowed_paths",
    { allowEmpty: false },
  );
  const forbidden_paths = requirePathList(
    input.forbidden_paths,
    "forbidden_paths",
    { allowEmpty: true },
  );
  const scope_constraints = requireText(
    input.scope_constraints,
    "scope_constraints",
  );

  const approval = loadGovernanceExecutionApproval(
    db,
    approval_id,
    envelope_id,
  );

  if (
    approval.package_id !== package_id ||
    approval.package_version !== package_version
  ) {
    throw new Error(
      "Execution scope package lineage does not match execution approval.",
    );
  }

  const existing = db
    .prepare(`
      SELECT approval_id
      FROM governance_execution_scopes
      WHERE approval_id = ?
         OR envelope_id = ?
      LIMIT 1
    `)
    .get(approval_id, envelope_id) as
      | { approval_id: string }
      | undefined;

  if (existing) {
    throw new Error(
      `Execution scope already exists for approval or envelope: ${approval_id} / ${envelope_id}`,
    );
  }

  const created_at = new Date().toISOString();

  db.prepare(`
    INSERT INTO governance_execution_scopes (
      approval_id,
      envelope_id,
      package_id,
      package_version,
      repo_path,
      expected_head,
      branch,
      allowed_paths,
      forbidden_paths,
      scope_constraints,
      created_at
    ) VALUES (
      @approval_id,
      @envelope_id,
      @package_id,
      @package_version,
      @repo_path,
      @expected_head,
      @branch,
      @allowed_paths,
      @forbidden_paths,
      @scope_constraints,
      @created_at
    )
  `).run({
    approval_id,
    envelope_id,
    package_id,
    package_version,
    repo_path,
    expected_head,
    branch,
    allowed_paths: JSON.stringify(allowed_paths),
    forbidden_paths: JSON.stringify(forbidden_paths),
    scope_constraints,
    created_at,
  });

  return loadGovernanceExecutionScope(
    db,
    approval_id,
    envelope_id,
  );
}

export function loadGovernanceExecutionScope(
  db: Database,
  approvalId: string,
  envelopeId: string,
): PersistedGovernanceExecutionScope {
  ensureGovernanceExecutionScopeTable(db);

  const approval_id = requireText(approvalId, "approval_id");
  const envelope_id = requireText(envelopeId, "envelope_id");

  const rows = db
    .prepare(`
      SELECT
        approval_id,
        envelope_id,
        package_id,
        package_version,
        repo_path,
        expected_head,
        branch,
        allowed_paths,
        forbidden_paths,
        scope_constraints,
        created_at
      FROM governance_execution_scopes
      WHERE approval_id = ?
        AND envelope_id = ?
      LIMIT 2
    `)
    .all(approval_id, envelope_id) as Array<{
      approval_id: string;
      envelope_id: string;
      package_id: string;
      package_version: number;
      repo_path: string;
      expected_head: string;
      branch: string;
      allowed_paths: string;
      forbidden_paths: string;
      scope_constraints: string;
      created_at: string;
    }>;

  if (rows.length !== 1) {
    throw new Error(
      `Execution scope not found or ambiguous: ${approval_id} / ${envelope_id}`,
    );
  }

  const row = rows[0];

  const approval = loadGovernanceExecutionApproval(
    db,
    approval_id,
    envelope_id,
  );

  if (
    approval.package_id !== row.package_id ||
    approval.package_version !== row.package_version
  ) {
    throw new Error(
      "Persisted execution scope lineage no longer matches execution approval.",
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
    envelope.package_id !== row.package_id ||
    envelope.package_version !== row.package_version
  ) {
    throw new Error(
      "Persisted execution scope lineage no longer matches governance envelope.",
    );
  }

  return {
    approval_id: row.approval_id,
    envelope_id: row.envelope_id,
    package_id: row.package_id,
    package_version: row.package_version,
    repo_path: requireText(row.repo_path, "repo_path"),
    expected_head: requireExpectedHead(row.expected_head),
    branch: requireText(row.branch, "branch"),
    allowed_paths: parsePersistedPathList(
      row.allowed_paths,
      "allowed_paths",
      { allowEmpty: false },
    ),
    forbidden_paths: parsePersistedPathList(
      row.forbidden_paths,
      "forbidden_paths",
      { allowEmpty: true },
    ),
    scope_constraints: requireText(
      row.scope_constraints,
      "scope_constraints",
    ),
    created_at: row.created_at,
  };
}
