import type { Database } from "better-sqlite3";

import {
  persistGovernanceExecutionScope,
} from "../../db/governance-execution-scope-persistence";
import {
  loadGovernanceExecutionApproval,
} from "../../db/governance-execution-approval-persistence";
import {
  loadGovernanceExecutionReadChain,
  type GovernanceExecutionReadIdentity,
} from "../../db/governance-execution-read-repository";
import {
  resolveRegisteredProjectRepository,
} from "../project-registry.mjs";
import {
  observeGovernedRepositoryState,
} from "./governed-repository-state-observer";

export type MaterializeGovernanceExecutionScopeInput = {
  approval_id: string;
  envelope_id: string;
  allowed_paths: string[];
  forbidden_paths: string[];
  scope_constraints: string;
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Execution scope materialization requires ${field}.`);
  }

  return value.trim();
}

function requirePathList(
  value: unknown,
  field: string,
  allowEmpty: boolean,
): string[] {
  if (!Array.isArray(value)) {
    throw new Error(
      `Execution scope materialization requires ${field} array.`,
    );
  }

  const paths = value.map((entry) => requireText(entry, field));

  if (!allowEmpty && paths.length === 0) {
    throw new Error(
      `Execution scope materialization requires non-empty ${field}.`,
    );
  }

  if (new Set(paths).size !== paths.length) {
    throw new Error(
      `Execution scope materialization ${field} must not contain duplicates.`,
    );
  }

  return paths;
}

function loadEnvelopeIdentity(
  db: Database,
  envelopeId: string,
): GovernanceExecutionReadIdentity {
  const rows = db.prepare(`
    SELECT
      envelope_id,
      package_id,
      package_version,
      delegation_id,
      validation_result_id,
      envelope_gate_id
    FROM governance_envelopes
    WHERE envelope_id = ?
    LIMIT 2
  `).all(envelopeId) as GovernanceExecutionReadIdentity[];

  if (rows.length !== 1) {
    throw new Error(
      `Governance execution envelope not found or ambiguous: ${envelopeId}`,
    );
  }

  return rows[0];
}

export function materializeGovernanceExecutionScope(
  db: Database,
  input: MaterializeGovernanceExecutionScopeInput,
) {
  const approvalId = requireText(input.approval_id, "approval_id");
  const envelopeId = requireText(input.envelope_id, "envelope_id");
  const allowedPaths = requirePathList(
    input.allowed_paths,
    "allowed_paths",
    false,
  );
  const forbiddenPaths = requirePathList(
    input.forbidden_paths,
    "forbidden_paths",
    true,
  );
  const scopeConstraints = requireText(
    input.scope_constraints,
    "scope_constraints",
  );

  const approval = loadGovernanceExecutionApproval(
    db,
    approvalId,
    envelopeId,
  );

  const identity = loadEnvelopeIdentity(db, envelopeId);
  const chain = loadGovernanceExecutionReadChain(db, identity);

  if (chain.governance.ok !== true) {
    throw new Error(
      "Execution scope materialization requires validated governance chain.",
    );
  }

  if (
    approval.package_id !== chain.envelope.package_id ||
    approval.package_version !== chain.envelope.package_version
  ) {
    throw new Error(
      "Execution scope materialization package lineage mismatch.",
    );
  }

  const projectId = requireText(
    chain.delegation.project_id,
    "project_id",
  );
  const repository = resolveRegisteredProjectRepository(projectId);

  const observed = observeGovernedRepositoryState({
    repoPath: repository.projectRootPath,
  });

  const registeredRepositoryReference = requireText(
    repository.gitRepositoryReference,
    "git_repository_reference",
  );

  if (observed.remote_url !== registeredRepositoryReference) {
    throw new Error(
      "Observed repository remote does not match registered repository identity.",
    );
  }

  return persistGovernanceExecutionScope(db, {
    approval_id: approvalId,
    envelope_id: envelopeId,
    package_id: approval.package_id,
    package_version: approval.package_version,
    repo_path: observed.repo_path,
    expected_head: observed.expected_head,
    branch: observed.branch,
    allowed_paths: allowedPaths,
    forbidden_paths: forbiddenPaths,
    scope_constraints: scopeConstraints,
  });
}
