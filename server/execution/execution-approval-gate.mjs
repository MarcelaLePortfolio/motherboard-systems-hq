import { evaluateExecutionSwitch } from "./matilda-execution-switch-evaluator.js";

function fail(code, message) {
  const err = new Error(message);
  err.code = code;
  throw err;
}

function normalizeVersionControlAuthorization(authorization = {}) {
  return {
    commit_authorized: authorization?.commit_authorized === true,
    push_authorized: authorization?.push_authorized === true,
    remote:
      typeof authorization?.remote === "string" &&
      authorization.remote.length > 0
        ? authorization.remote
        : "origin",
    branch:
      typeof authorization?.branch === "string" &&
      authorization.branch.length > 0
        ? authorization.branch
        : null,
  };
}

function normalizeApproval(approval = {}) {
  return {
    approval_id: approval?.approval_id ?? null,
    approved_by: approval?.approved_by ?? null,
    approval_scope: approval?.approval_scope ?? "none",
    mutation_authorized: approval?.mutation_authorized === true,
    shell_execution_authorized: approval?.shell_execution_authorized === true,
    autonomous_execution_authorized:
      approval?.autonomous_execution_authorized === true,
    version_control_authorization:
      normalizeVersionControlAuthorization(
        approval?.version_control_authorization,
      ),
    issued_at: approval?.issued_at ?? null,
    expires_at: approval?.expires_at ?? null,
    justification: approval?.justification ?? null,
    status: approval?.status ?? null,
  };
}

function hasNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function hasAllowedPaths(envelope = {}) {
  return (
    Array.isArray(envelope?.mutation_scope?.allowed_paths) &&
    envelope.mutation_scope.allowed_paths.length > 0
  );
}

function shouldGrantGovernedCommitAuthority({
  envelope = {},
  normalized = {},
} = {}) {
  const vc = normalized.version_control_authorization;

  return (
    envelope?.delegation_authorization?.state === "delegated" &&
    normalized.approval_id !== null &&
    normalized.status === "approved" &&
    vc.commit_authorized === true &&
    vc.push_authorized === false &&
    hasNonEmptyString(envelope?.project_target?.expected_head) &&
    hasNonEmptyString(envelope?.project_target?.repo_path) &&
    hasNonEmptyString(envelope?.project_target?.branch) &&
    hasAllowedPaths(envelope)
  );
}

export function evaluateExecutionApproval({
  envelope = {},
  governance = {},
  approval = {},
} = {}) {
  const normalized = normalizeApproval(approval);

  if (!governance?.ok) {
    fail(
      "GOVERNANCE_VALIDATION_REQUIRED",
      "approval gate requires successful governance validation",
    );
  }

  if (normalized.mutation_authorized === true) {
    fail(
      "MUTATION_AUTHORITY_DISABLED",
      "mutation authority remains disabled in current execution phase",
    );
  }

  if (normalized.shell_execution_authorized === true) {
    fail(
      "SHELL_AUTHORITY_DISABLED",
      "shell execution authority remains disabled in current execution phase",
    );
  }

  if (normalized.autonomous_execution_authorized === true) {
    fail(
      "AUTONOMOUS_AUTHORITY_DISABLED",
      "autonomous execution authority remains disabled in current execution phase",
    );
  }

  if (normalized.version_control_authorization.push_authorized === true) {
    fail(
      "PUSH_AUTHORITY_DISABLED",
      "push authority remains disabled in the local commit phase",
    );
  }

  const commitAuthorized = shouldGrantGovernedCommitAuthority({
    envelope,
    normalized,
  });

  return {
    ok: true,
    approval_gate: "canonical_execution_approval_gate",
    execution_phase: commitAuthorized
      ? "governed_version_control_commit"
      : "governed_planning_only",
    delegated:
      envelope?.delegation_authorization?.state === "delegated",
    approval_present: normalized.approval_id !== null,
    mutation_authorized: false,
    shell_execution_authorized: false,
    autonomous_execution_authorized: false,
    version_control_authorization: {
      ...normalized.version_control_authorization,
      commit_authorized: commitAuthorized,
      push_authorized: false,
    },
    approval_artifact: normalized,
    trace: [
      {
        event: "approval_artifact_normalized",
        ok: true,
      },
      {
        event: "governance_validated",
        ok: true,
      },
      {
        event: "delegation_validated",
        ok:
          envelope?.delegation_authorization?.state ===
          "delegated",
      },
      {
        event: commitAuthorized
          ? "version_control_commit_authority_granted"
          : "version_control_commit_authority_blocked",
        ok: true,
      },
      {
        event: "push_authority_blocked",
        ok: true,
      },
      {
        event: "mutation_authority_blocked",
        ok: true,
      },
      {
        event: "shell_authority_blocked",
        ok: true,
      },
      {
        event: "autonomous_authority_blocked",
        ok: true,
      },
    ],
  };
}
