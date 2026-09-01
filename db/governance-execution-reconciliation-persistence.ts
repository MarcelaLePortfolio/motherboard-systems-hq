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
  prior_commit_execution_id?: string | null;
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
  prior_commit_execution_id: string | null;
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
  prior_commit_execution_id?: string | null;
  local_effect_status: GovernanceExecutionEffectStatus;
  remote_effect_status: GovernanceExecutionEffectStatus;
}) {
  if (
    input.push_requested &&
    !input.commit_requested &&
    !input.prior_commit_execution_id
  ) {
    throw new Error(
      "Execution reconciliation requires prior_commit_execution_id for push without a new commit.",
    );
  }

  if (
    input.prior_commit_execution_id &&
    (!input.push_requested || input.commit_requested)
  ) {
    throw new Error(
      "Execution reconciliation accepts prior_commit_execution_id only for push without a new commit.",
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

  if (input.stage === "PUSH_CONFIRMED") {
    const sameExecutionCommitPush =
      input.commit_requested === true &&
      input.push_requested === true &&
      !input.prior_commit_execution_id &&
      input.local_effect_status === "confirmed" &&
      input.remote_effect_status === "confirmed";

    const certifiedPriorCommitPush =
      input.commit_requested === false &&
      input.push_requested === true &&
      Boolean(input.prior_commit_execution_id) &&
      input.local_effect_status === "none" &&
      input.remote_effect_status === "confirmed";

    if (!sameExecutionCommitPush && !certifiedPriorCommitPush) {
      throw new Error(
        "PUSH_CONFIRMED requires same-execution commit confirmation or certified prior-commit push confirmation.",
      );
    }
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
      prior_commit_execution_id TEXT,
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

  const columns = db
    .prepare(
      "PRAGMA table_info(governance_execution_reconciliation_entries)",
    )
    .all() as Array<{ name: string }>;

  if (
    !columns.some(
      (column) =>
        column.name === "prior_commit_execution_id",
    )
  ) {
    db.exec(`
      ALTER TABLE governance_execution_reconciliation_entries
      ADD COLUMN prior_commit_execution_id TEXT
    `);
  }
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
    prior_commit_execution_id:
      row.prior_commit_execution_id === null ||
      row.prior_commit_execution_id === undefined
        ? null
        : requireText(
            row.prior_commit_execution_id,
            "prior_commit_execution_id",
          ),
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

export type CertifiedGovernedLocalCommitProof = {
  status: "ok";
  pre_head: string;
  post_head: string;
  branch: string;
  approval_id: string;
  envelope_id: string;
  execution_id: string;
  project_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  envelope_gate_id: string;
  repo_path: string;
  expected_head: string;
  remote_effect: false;
  push_effect: false;
};

export function loadCertifiedGovernedLocalCommitProof(
  db: Database,
  executionId: string,
): CertifiedGovernedLocalCommitProof {
  const entries =
    listGovernanceExecutionReconciliationEntries(
      db,
      requireText(executionId, "execution_id"),
    );

  if (entries.length !== 2) {
    throw new Error(
      "Certified local commit proof requires exactly EXECUTION_STARTED followed by terminal COMMIT_CONFIRMED.",
    );
  }

  const [started, committed] = entries;

  if (
    started.stage !== "EXECUTION_STARTED" ||
    committed.stage !== "COMMIT_CONFIRMED"
  ) {
    throw new Error(
      "Certified local commit proof requires terminal commit-only reconciliation lineage.",
    );
  }

  for (const entry of entries) {
    if (
      entry.commit_requested !== true ||
      entry.push_requested !== false
    ) {
      throw new Error(
        "Certified local commit proof requires commit_requested=true and push_requested=false.",
      );
    }

    if (
      entry.execution_id !== started.execution_id ||
      entry.project_id !== started.project_id ||
      entry.package_id !== started.package_id ||
      entry.package_version !== started.package_version ||
      entry.delegation_id !== started.delegation_id ||
      entry.validation_result_id !== started.validation_result_id ||
      entry.envelope_gate_id !== started.envelope_gate_id ||
      entry.approval_id !== started.approval_id ||
      entry.envelope_id !== started.envelope_id ||
      entry.repo_path !== started.repo_path ||
      entry.expected_head !== started.expected_head ||
      entry.branch !== started.branch
    ) {
      throw new Error(
        "Certified local commit proof reconciliation lineage is inconsistent.",
      );
    }
  }

  if (
    committed.local_effect_status !== "confirmed" ||
    committed.remote_effect_status !== "none"
  ) {
    throw new Error(
      "Certified local commit proof requires confirmed local effect and no remote effect.",
    );
  }

  const evidence = committed.evidence;

  if (!evidence) {
    throw new Error(
      "Certified local commit proof requires COMMIT_CONFIRMED evidence.",
    );
  }

  const preHead = evidence.pre_head;
  const postHead = evidence.post_head;
  const branch = evidence.branch;

  if (
    typeof preHead !== "string" ||
    !/^[0-9a-f]{40}$/i.test(preHead) ||
    typeof postHead !== "string" ||
    !/^[0-9a-f]{40}$/i.test(postHead) ||
    typeof branch !== "string" ||
    branch.trim().length === 0
  ) {
    throw new Error(
      "Certified local commit proof evidence is incomplete or invalid.",
    );
  }

  if (branch !== committed.branch) {
    throw new Error(
      "Certified local commit proof branch does not match durable reconciliation scope.",
    );
  }

  if (preHead !== committed.expected_head) {
    throw new Error(
      "Certified local commit proof pre_head does not match durable reconciliation expected_head.",
    );
  }

  return {
    status: "ok",
    pre_head: preHead,
    post_head: postHead,
    branch,
    approval_id: committed.approval_id,
    envelope_id: committed.envelope_id,
    execution_id: committed.execution_id,
    project_id: committed.project_id,
    package_id: committed.package_id,
    package_version: committed.package_version,
    delegation_id: committed.delegation_id,
    validation_result_id: committed.validation_result_id,
    envelope_gate_id: committed.envelope_gate_id,
    repo_path: committed.repo_path,
    expected_head: committed.expected_head,
    remote_effect: false,
    push_effect: false,
  };
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
    prior_commit_execution_id:
      raw.prior_commit_execution_id === undefined ||
      raw.prior_commit_execution_id === null
        ? null
        : requireText(
            raw.prior_commit_execution_id,
            "prior_commit_execution_id",
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
        first.push_requested !== input.push_requested ||
        first.prior_commit_execution_id !==
          input.prior_commit_execution_id
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
        !input.prior_commit_execution_id &&
        !existing.some(
          (entry) => entry.stage === "COMMIT_CONFIRMED",
        )
      ) {
        throw new Error(
          "PUSH_CONFIRMED requires prior COMMIT_CONFIRMED or certified prior commit execution reference.",
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
        prior_commit_execution_id,
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
        @prior_commit_execution_id,
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
      prior_commit_execution_id:
        input.prior_commit_execution_id,
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
