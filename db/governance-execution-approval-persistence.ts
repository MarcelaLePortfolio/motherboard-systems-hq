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
