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
    shell_execution_authorized:
      approval?.shell_execution_authorized === true,
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
  return (
    typeof value === "string" &&
    value.trim().length > 0
  );
}

function hasAllowedPaths(envelope = {}) {
  return (
    Array.isArray(
      envelope?.mutation_scope?.allowed_paths,
    ) &&
    envelope.mutation_scope.allowed_paths.length > 0
  );
}

function shouldGrantGovernedCommitAuthority({
  envelope = {},
  normalized = {},
} = {}) {
  const vc =
    normalized.version_control_authorization;

  return (
    envelope?.delegation_authorization?.state ===
      "delegated" &&
    normalized.approval_id !== null &&
    normalized.status === "approved" &&
    vc.commit_authorized === true &&
    vc.push_authorized === false &&
    hasNonEmptyString(
      envelope?.project_target?.expected_head,
    ) &&
    hasNonEmptyString(
      envelope?.project_target?.repo_path,
    ) &&
    hasNonEmptyString(
      envelope?.project_target?.branch,
    ) &&
    hasAllowedPaths(envelope)
  );
}

function normalizeLocalCommitResult(
  localCommitResult = null,
) {
  if (
    !localCommitResult ||
    typeof localCommitResult !== "object"
  ) {
    return null;
  }

  return {
    status: localCommitResult?.status ?? null,
    pre_head:
      localCommitResult?.pre_head ??
      localCommitResult?.preHead ??
      null,
    post_head:
      localCommitResult?.post_head ??
      localCommitResult?.postHead ??
      null,
    branch:
      localCommitResult?.branch ?? null,
    approval_id:
      localCommitResult?.approval_id ??
      localCommitResult?.approvalId ??
      null,
    envelope_id:
      localCommitResult?.envelope_id ??
      localCommitResult?.envelopeId ??
      null,
    execution_id:
      localCommitResult?.execution_id ??
      localCommitResult?.executionId ??
      null,
    remote_effect:
      localCommitResult?.remote_effect ??
      localCommitResult?.remoteEffect ??
      null,
    push_effect:
      localCommitResult?.push_effect ??
      localCommitResult?.pushEffect ??
      null,
    project_id:
      localCommitResult?.project_id ?? null,
    package_id:
      localCommitResult?.package_id ?? null,
    package_version:
      localCommitResult?.package_version ?? null,
    delegation_id:
      localCommitResult?.delegation_id ?? null,
    validation_result_id:
      localCommitResult?.validation_result_id ?? null,
    envelope_gate_id:
      localCommitResult?.envelope_gate_id ?? null,
    repo_path:
      localCommitResult?.repo_path ?? null,
    expected_head:
      localCommitResult?.expected_head ?? null,
  };
}

function validatePushAuthorityProof({
  envelope = {},
  normalized = {},
  localCommitResult = null,
} = {}) {
  const vc =
    normalized.version_control_authorization;

  if (vc.push_authorized !== true) {
    return {
      requested: false,
      authorized: false,
      local_commit_result: null,
      expected_push_head: null,
    };
  }

  if (vc.commit_authorized !== true) {
    fail(
      "PUSH_REQUIRES_COMMIT_AUTHORITY",
      "push authority requires commit_authorized=true",
    );
  }

  if (
    envelope?.delegation_authorization?.state !==
    "delegated"
  ) {
    fail(
      "PUSH_REQUIRES_DELEGATION",
      "push authority requires delegated envelope",
    );
  }

  if (normalized.approval_id === null) {
    fail(
      "PUSH_REQUIRES_APPROVAL",
      "push authority requires approval artifact",
    );
  }

  if (normalized.status !== "approved") {
    fail(
      "PUSH_REQUIRES_APPROVED_STATUS",
      "push authority requires approved status",
    );
  }

  if (
    !hasNonEmptyString(
      envelope?.project_target?.expected_head,
    )
  ) {
    fail(
      "PUSH_EXPECTED_HEAD_REQUIRED",
      "push authority requires expected_head",
    );
  }

  if (
    !hasNonEmptyString(
      envelope?.project_target?.repo_path,
    )
  ) {
    fail(
      "PUSH_REPO_PATH_REQUIRED",
      "push authority requires repo_path",
    );
  }

  if (
    !hasNonEmptyString(
      envelope?.project_target?.branch,
    )
  ) {
    fail(
      "PUSH_BRANCH_REQUIRED",
      "push authority requires branch",
    );
  }

  const local =
    normalizeLocalCommitResult(
      localCommitResult,
    );

  if (!local) {
    fail(
      "LOCAL_COMMIT_RESULT_REQUIRED",
      "push authority requires successful local commit result",
    );
  }

  if (local.status !== "ok") {
    fail(
      "LOCAL_COMMIT_RESULT_NOT_SUCCESSFUL",
      "push authority requires local commit status=ok",
    );
  }

  for (const [key, message] of [
    ["pre_head", "local commit pre_head required"],
    ["post_head", "local commit post_head required"],
    ["branch", "local commit branch required"],
    ["approval_id", "local commit approval_id required"],
    ["envelope_id", "local commit envelope_id required"],
    ["execution_id", "local commit execution_id required"],
  ]) {
    if (!hasNonEmptyString(local[key])) {
      fail(
        "LOCAL_COMMIT_PROOF_INCOMPLETE",
        message,
      );
    }
  }

  if (local.remote_effect !== false) {
    fail(
      "LOCAL_COMMIT_REMOTE_EFFECT_INVALID",
      "local commit proof must have remote_effect=false",
    );
  }

  if (local.push_effect !== false) {
    fail(
      "LOCAL_COMMIT_PUSH_EFFECT_INVALID",
      "local commit proof must have push_effect=false",
    );
  }

  const envelopeId =
    envelope?.identity?.envelope_id ?? null;

  const certifiedPriorCommit =
    hasNonEmptyString(local.project_id) &&
    hasNonEmptyString(local.package_id) &&
    Number.isInteger(local.package_version) &&
    hasNonEmptyString(local.delegation_id) &&
    hasNonEmptyString(local.validation_result_id) &&
    hasNonEmptyString(local.envelope_gate_id) &&
    hasNonEmptyString(local.repo_path) &&
    hasNonEmptyString(local.expected_head);

  if (!certifiedPriorCommit) {
    if (
      local.approval_id !==
      normalized.approval_id
    ) {
      fail(
        "LOCAL_COMMIT_APPROVAL_ID_MISMATCH",
        "local commit approval_id must match approval artifact",
      );
    }

    if (
      local.envelope_id !==
      envelopeId
    ) {
      fail(
        "LOCAL_COMMIT_ENVELOPE_ID_MISMATCH",
        "local commit envelope_id must match envelope",
      );
    }
  } else {
    if (
      local.package_id !==
        envelope?.identity?.package_id ||
      local.package_version !==
        envelope?.identity?.package_version
    ) {
      fail(
        "LOCAL_COMMIT_PACKAGE_LINEAGE_MISMATCH",
        "certified prior local commit package lineage must match current envelope",
      );
    }

    if (
      local.repo_path !==
      envelope?.project_target?.repo_path
    ) {
      fail(
        "LOCAL_COMMIT_REPO_PATH_MISMATCH",
        "certified prior local commit repo_path must match current envelope",
      );
    }

    if (
      local.post_head !==
      envelope?.project_target?.expected_head
    ) {
      fail(
        "LOCAL_COMMIT_EXPECTED_HEAD_MISMATCH",
        "certified prior local commit post_head must match current envelope expected_head",
      );
    }
  }

  if (
    local.branch !==
    envelope?.project_target?.branch
  ) {
    fail(
      "LOCAL_COMMIT_BRANCH_MISMATCH",
      "local commit branch must match envelope branch",
    );
  }

  return {
    requested: true,
    authorized: true,
    local_commit_result: local,
    expected_push_head: local.post_head,
  };
}

export function evaluateExecutionApproval({
  envelope = {},
  governance = {},
  approval = {},
  localCommitResult = null,
} = {}) {
  const normalized =
    normalizeApproval(approval);

  if (!governance?.ok) {
    fail(
      "GOVERNANCE_VALIDATION_REQUIRED",
      "approval gate requires successful governance validation",
    );
  }

  if (
    normalized.mutation_authorized === true
  ) {
    fail(
      "MUTATION_AUTHORITY_DISABLED",
      "mutation authority remains disabled in current execution phase",
    );
  }

  if (
    normalized.shell_execution_authorized === true
  ) {
    fail(
      "SHELL_AUTHORITY_DISABLED",
      "shell execution authority remains disabled in current execution phase",
    );
  }

  if (
    normalized.autonomous_execution_authorized === true
  ) {
    fail(
      "AUTONOMOUS_AUTHORITY_DISABLED",
      "autonomous execution authority remains disabled in current execution phase",
    );
  }

  const pushProof =
    validatePushAuthorityProof({
      envelope,
      normalized,
      localCommitResult,
    });

  const commitAuthorized =
    pushProof.authorized === true
      ? true
      : shouldGrantGovernedCommitAuthority({
          envelope,
          normalized,
        });

  const executionPhase =
    pushProof.authorized === true
      ? "governed_version_control_push"
      : commitAuthorized
        ? "governed_version_control_commit"
        : "governed_planning_only";

  return {
    ok: true,
    approval_gate:
      "canonical_execution_approval_gate",
    execution_phase: executionPhase,
    delegated:
      envelope?.delegation_authorization?.state ===
      "delegated",
    approval_present:
      normalized.approval_id !== null,
    mutation_authorized: false,
    shell_execution_authorized: false,
    autonomous_execution_authorized: false,
    version_control_authorization: {
      ...normalized.version_control_authorization,
      commit_authorized: commitAuthorized,
      push_authorized:
        pushProof.authorized === true,
    },
    expected_push_head:
      pushProof.expected_push_head,
    approval_artifact: normalized,
    local_commit_result:
      pushProof.local_commit_result,
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
          envelope?.delegation_authorization
            ?.state === "delegated",
      },
      {
        event:
          pushProof.authorized === true
            ? "governed_local_commit_verified"
            : "governed_local_commit_not_required",
        ok: true,
      },
      {
        event:
          pushProof.authorized === true
            ? "push_authority_granted"
            : "push_authority_blocked",
        ok: true,
      },
      {
        event:
          commitAuthorized
            ? "version_control_commit_authority_granted"
            : "version_control_commit_authority_blocked",
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
