#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT NARROW PUSH APPROVAL GATE TRANSITION ==="
echo "MODE=EXECUTION"
echo "REMOTE_PUSH_EFFECT_IMPLEMENTATION_AUTHORIZED=NO"
echo "REMOTE_PUSH_EXECUTION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="46e5d4394"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

cat > server/execution/execution-approval-gate.mjs << 'FILEEOF'
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

  if (!hasNonEmptyString(vc.remote)) {
    fail(
      "PUSH_REMOTE_REQUIRED",
      "push authority requires approved remote",
    );
  }

  if (!hasNonEmptyString(vc.branch)) {
    fail(
      "PUSH_AUTHORIZED_BRANCH_REQUIRED",
      "push authority requires approved branch",
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

  if (
    local.approval_id !==
    normalized.approval_id
  ) {
    fail(
      "LOCAL_COMMIT_APPROVAL_ID_MISMATCH",
      "local commit approval_id must match approval artifact",
    );
  }

  const envelopeId =
    envelope?.identity?.envelope_id ?? null;

  if (
    local.envelope_id !==
    envelopeId
  ) {
    fail(
      "LOCAL_COMMIT_ENVELOPE_ID_MISMATCH",
      "local commit envelope_id must match envelope",
    );
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

  if (
    vc.branch !==
    envelope?.project_target?.branch
  ) {
    fail(
      "AUTHORIZED_BRANCH_MISMATCH",
      "approved branch must match envelope branch",
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
FILEEOF

cat > server/execution/smoke-test-version-control-push-approval.mjs << 'FILEEOF'
import assert from "node:assert/strict";

import { createExecutionEnvelope } from "../contracts/execution-envelope.v1.mjs";
import { buildApprovalArtifact } from "./build-approval-artifact.mjs";
import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";
import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

const head = "a".repeat(40);

function buildEnvelope() {
  return createExecutionEnvelope({
    identity: {
      envelope_id:
        "env-push-approval-smoke",
      intent_id:
        "intent-push-approval-smoke",
    },
    intent: {
      raw_user_intent:
        "validate push approval",
      normalized_intent:
        "validate push approval",
      intent_type: "inspect",
      intent_evidence: [
        "user_authorization",
      ],
      confidence_score: 1,
    },
    project_target: {
      project_name:
        "Motherboard Systems",
      repo_path: process.cwd(),
      branch:
        "feature/support-source-references-runtime",
      expected_head: head,
      workspace_type:
        "motherboard_systems",
    },
    mutation_scope: {
      scope_type: "file",
      allowed_paths: [
        "docs/contracts/",
      ],
      forbidden_paths: [
        "secrets/",
        ".env",
      ],
      scope_constraints:
        "push approval smoke only",
    },
    execution_plan: {
      summary:
        "validate push approval",
      steps: [
        {
          step_id: "step-1",
          action: "inspect",
          target:
            "docs/contracts/example.md",
          instructions:
            "approval only",
          expected_output:
            "approval result",
        },
      ],
    },
    patch_spec: {
      format:
        "structured_patch",
      patches: [
        {
          file:
            "docs/contracts/example.md",
          operation: "modify",
          content: "planned only",
        },
      ],
    },
    validation_contract: {
      pre_checks: [],
      post_checks: [],
      success_criteria: [
        "push approval validation succeeds",
      ],
      failure_conditions: [],
    },
    rollback_contract: {
      rollback_supported: true,
      rollback_method: "git",
      rollback_trigger_conditions: [
        "validation failure",
      ],
    },
    reconciliation: {
      required: true,
      reconciliation_type:
        "diff_based",
    },
    sandbox: {
      dry_run_required: true,
      sandbox_mode: "strict",
      allow_external_side_effects:
        false,
    },
    execution_mode: {
      mutation_allowed: false,
      shell_execution_allowed: false,
      autonomous_execution_allowed:
        false,
    },
    delegation_authorization: {
      required: true,
      state: "delegated",
      notes:
        "push approval smoke only",
    },
  });
}

function approvedVc({
  push = false,
} = {}) {
  return {
    ...buildApprovalArtifact({
      version_control_authorization: {
        commit_authorized: true,
        push_authorized: push,
        remote: "origin",
        branch:
          "feature/support-source-references-runtime",
      },
    }),
    status: "approved",
  };
}

function localCommitResult({
  status = "ok",
  postHead = "b".repeat(40),
  branch =
    "feature/support-source-references-runtime",
  approvalId,
  envelopeId =
    "env-push-approval-smoke",
  remoteEffect = false,
  pushEffect = false,
} = {}) {
  return {
    status,
    preHead: head,
    postHead,
    branch,
    approvalId,
    envelopeId,
    executionId:
      "execution-push-smoke",
    remoteEffect,
    pushEffect,
  };
}

const envelope = buildEnvelope();
const governance =
  validateGovernedExecutionEnvelope(
    envelope,
  );

const ordinary =
  evaluateExecutionApproval({
    envelope,
    governance,
    approval:
      buildApprovalArtifact(),
  });

assert.equal(
  ordinary.execution_phase,
  "governed_planning_only",
);

const commitApproval =
  approvedVc({
    push: false,
  });

const commitOnly =
  evaluateExecutionApproval({
    envelope,
    governance,
    approval: commitApproval,
  });

assert.equal(
  commitOnly.execution_phase,
  "governed_version_control_commit",
);

assert.equal(
  commitOnly
    .version_control_authorization
    .push_authorized,
  false,
);

const pushApproval =
  approvedVc({
    push: true,
  });

const proof =
  localCommitResult({
    approvalId:
      pushApproval.approval_id,
  });

const pushed =
  evaluateExecutionApproval({
    envelope,
    governance,
    approval: pushApproval,
    localCommitResult: proof,
  });

assert.equal(
  pushed.execution_phase,
  "governed_version_control_push",
);

assert.equal(
  pushed
    .version_control_authorization
    .commit_authorized,
  true,
);

assert.equal(
  pushed
    .version_control_authorization
    .push_authorized,
  true,
);

assert.equal(
  pushed.mutation_authorized,
  false,
);

assert.equal(
  pushed.shell_execution_authorized,
  false,
);

assert.equal(
  pushed.autonomous_execution_authorized,
  false,
);

assert.equal(
  pushed.expected_push_head,
  proof.postHead,
);

assert.equal(
  pushed.trace.some(
    (entry) =>
      entry.event ===
      "governed_local_commit_verified",
  ),
  true,
);

assert.equal(
  pushed.trace.some(
    (entry) =>
      entry.event ===
      "push_authority_granted",
  ),
  true,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
    }),
  /local commit result/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          status: "failed",
        }),
    }),
  /status=ok/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            "wrong-approval",
        }),
    }),
  /approval_id/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          envelopeId:
            "wrong-envelope",
        }),
    }),
  /envelope_id/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          branch:
            "wrong-branch",
        }),
    }),
  /branch/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          remoteEffect: true,
        }),
    }),
  /remote_effect=false/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          pushEffect: true,
        }),
    }),
  /push_effect=false/,
);

console.log(
  JSON.stringify(
    {
      ok: true,
      ordinary_planning_preserved:
        true,
      commit_only_phase_preserved:
        true,
      push_authority_granted:
        true,
      successful_local_commit_required:
        true,
      approval_correlation:
        true,
      envelope_correlation:
        true,
      branch_correlation:
        true,
      mutation_authority:
        false,
      shell_authority:
        false,
      autonomous_authority:
        false,
      git_side_effects:
        false,
      remote_write:
        false,
    },
    null,
    2,
  ),
);
FILEEOF

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== EXISTING VERSION CONTROL CONTRACT SMOKE ==="
npx tsx server/execution/smoke-test-version-control-contract.mjs
echo "VERSION_CONTROL_CONTRACT_SMOKE=PASS"

echo
echo "=== PUSH APPROVAL TRANSITION SMOKE ==="
npx tsx server/execution/smoke-test-version-control-push-approval.mjs
echo "PUSH_APPROVAL_SMOKE=PASS"

echo
echo "=== VERIFY NO PROCESS / PUSH EFFECT IN APPROVAL UNIT ==="
node - <<'NODE'
const fs = require("fs");

const files = [
  "server/execution/execution-approval-gate.mjs",
  "server/execution/smoke-test-version-control-contract.mjs",
  "server/execution/smoke-test-version-control-push-approval.mjs",
];

const prohibited = [
  /node:child_process/,
  /\bexecFile(?:Sync)?\s*\(/,
  /\bexec(?:Sync)?\s*\(/,
  /\bspawn(?:Sync)?\s*\(/,
  /\bgit\s+push\b/,
];

for (const file of files) {
  const source =
    fs.readFileSync(
      file,
      "utf8",
    );

  for (const pattern of prohibited) {
    if (pattern.test(source)) {
      throw new Error(
        `prohibited process or push effect in ${file}`,
      );
    }
  }
}

console.log("APPROVAL_UNIT_SIDE_EFFECTS=NONE");
NODE

echo
echo "=== VERIFY PROTECTED SURFACES UNCHANGED ==="
if git diff -- \
  server/cade/cade-version-control-effects.ts \
  server/execution/cade-governed-commit-adapter.ts \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts \
  server/execution/governance-validator.mjs \
  server/execution/matilda-execution-switch-evaluator.ts \
  | grep -q .; then
  echo "STOP: prohibited surface changed"
  exit 1
fi

echo "PROTECTED_SURFACES_UNCHANGED=YES"

AUTHORIZED_FILES=(
  server/execution/execution-approval-gate.mjs
  server/execution/smoke-test-version-control-push-approval.mjs
)

if [[ -n "$(git diff --cached --name-only)" ]]; then
  echo "STOP: pre-existing staged files detected"
  git diff --cached --name-only
  exit 1
fi

git add "${AUTHORIZED_FILES[@]}"

EXPECTED="$(
  printf '%s\n' "${AUTHORIZED_FILES[@]}" | sort
)"

ACTUAL="$(
  git diff --cached --name-only | sort
)"

echo "STAGED_FILES:"
printf '%s\n' "${ACTUAL}"

if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo "STOP: staged set exceeds authorized push approval unit"
  git restore --staged -- "${AUTHORIZED_FILES[@]}"
  exit 1
fi

git commit -m "Enable narrow governed Cade push approval"
git push

echo
echo "NARROW_PUSH_APPROVAL_TRANSITION=COMMITTED_AND_PUSHED"
echo "REMOTE_PUSH_EFFECT=NOT_IMPLEMENTED"
echo "REMOTE_PUSH_EXECUTION=NOT_ENABLED"
echo "NEXT_ACTION=VALIDATE_AND_CLOSE_PUSH_APPROVAL_TRANSITION_BEFORE_PUSH_EFFECT_AUTHORIZATION"
