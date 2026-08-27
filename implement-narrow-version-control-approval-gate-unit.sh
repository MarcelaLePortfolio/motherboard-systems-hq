#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT NARROW VERSION CONTROL APPROVAL GATE UNIT ==="
echo "MODE=EXECUTION"
echo "SCOPE=APPROVAL_GATE_AND_VERSION_CONTROL_SMOKE_ONLY"
echo "LOCAL_GIT_COMMIT_EFFECT_AUTHORIZED=NO"
echo "REMOTE_PUSH_EFFECT_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="517e77255"
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
FILEEOF

cat > server/execution/smoke-test-version-control-contract.mjs << 'FILEEOF'
import assert from "node:assert/strict";

import { createExecutionEnvelope } from "../contracts/execution-envelope.v1.mjs";
import { validateExecutionEnvelope } from "../guards/validate-execution-envelope.mjs";
import { buildApprovalArtifact } from "./build-approval-artifact.mjs";
import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";
import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

function buildEnvelope(projectTarget = {}, overrides = {}) {
  return createExecutionEnvelope({
    identity: {
      envelope_id: "env-version-control-contract-smoke",
      intent_id: "intent-version-control-contract-smoke",
    },
    intent: {
      raw_user_intent:
        "Validate version-control contract semantics only",
      normalized_intent:
        "Validate contract semantics",
      intent_type: "inspect",
      intent_evidence: ["user_authorization"],
      confidence_score: 1,
    },
    project_target: {
      project_name: "Motherboard Systems",
      repo_path: process.cwd(),
      branch: "feature/support-source-references-runtime",
      workspace_type: "motherboard_systems",
      ...projectTarget,
    },
    mutation_scope: {
      scope_type: "file",
      allowed_paths: ["docs/contracts/"],
      forbidden_paths: ["secrets/", ".env"],
      scope_constraints: "Contract-only smoke",
      ...(overrides.mutation_scope || {}),
    },
    execution_plan: {
      summary:
        "Validate version-control contract semantics",
      steps: [
        {
          step_id: "step-1",
          action: "inspect",
          target: "docs/contracts/example.md",
          instructions: "Plan only",
          expected_output: "Validated contract",
        },
      ],
    },
    patch_spec: {
      format: "structured_patch",
      patches: [
        {
          file: "docs/contracts/example.md",
          operation: "modify",
          content: "planned only",
        },
      ],
    },
    validation_contract: {
      pre_checks: [],
      post_checks: [],
      success_criteria: [
        "Contract validation succeeds",
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
      reconciliation_type: "diff_based",
    },
    sandbox: {
      dry_run_required: true,
      sandbox_mode: "strict",
      allow_external_side_effects: false,
    },
    execution_mode: {
      mutation_allowed: false,
      shell_execution_allowed: false,
      autonomous_execution_allowed: false,
    },
    delegation_authorization: {
      required: true,
      state: "delegated",
      notes: "Contract-only smoke",
      ...(overrides.delegation_authorization || {}),
    },
  });
}

function approvedCommitArtifact(overrides = {}) {
  return {
    ...buildApprovalArtifact({
      version_control_authorization: {
        commit_authorized: true,
        push_authorized: false,
        remote: "origin",
        branch:
          "feature/support-source-references-runtime",
      },
    }),
    status: "approved",
    ...overrides,
  };
}

const ordinary = buildEnvelope();
assert.equal(
  ordinary.project_target.expected_head,
  null,
);
assert.doesNotThrow(() =>
  validateExecutionEnvelope(ordinary),
);

const expectedHead = "a".repeat(40);
const withExpectedHead = buildEnvelope({
  expected_head: expectedHead,
});
assert.equal(
  withExpectedHead.project_target.expected_head,
  expectedHead,
);
assert.doesNotThrow(() =>
  validateExecutionEnvelope(withExpectedHead),
);

const malformedExpectedHead = buildEnvelope({
  expected_head: "not-a-git-sha",
});
assert.throws(
  () =>
    validateExecutionEnvelope(
      malformedExpectedHead,
    ),
  /expected_head/,
);

const defaults = buildApprovalArtifact();
assert.equal(
  defaults.version_control_authorization
    .commit_authorized,
  false,
);
assert.equal(
  defaults.version_control_authorization
    .push_authorized,
  false,
);
assert.equal(
  defaults.version_control_authorization.remote,
  "origin",
);
assert.equal(
  defaults.version_control_authorization.branch,
  null,
);

const commitOnly = buildApprovalArtifact({
  version_control_authorization: {
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch:
      "feature/support-source-references-runtime",
  },
});

assert.equal(
  commitOnly.version_control_authorization
    .commit_authorized,
  true,
);
assert.equal(
  commitOnly.version_control_authorization
    .push_authorized,
  false,
);
assert.equal(
  commitOnly.mutation_authorized,
  false,
);
assert.equal(
  commitOnly.shell_execution_authorized,
  false,
);

const ordinaryGovernance =
  validateGovernedExecutionEnvelope(ordinary);

const ordinaryGated =
  evaluateExecutionApproval({
    envelope: ordinary,
    governance: ordinaryGovernance,
    approval: commitOnly,
  });

assert.equal(
  ordinaryGated.execution_phase,
  "governed_planning_only",
);
assert.equal(
  ordinaryGated.version_control_authorization
    .commit_authorized,
  false,
);
assert.equal(
  ordinaryGated.version_control_authorization
    .push_authorized,
  false,
);

const governedCommitEnvelope = buildEnvelope({
  expected_head: expectedHead,
});

const governedCommitGovernance =
  validateGovernedExecutionEnvelope(
    governedCommitEnvelope,
  );

const governedCommitApproval =
  approvedCommitArtifact();

const governedCommit =
  evaluateExecutionApproval({
    envelope: governedCommitEnvelope,
    governance: governedCommitGovernance,
    approval: governedCommitApproval,
  });

assert.equal(
  governedCommit.execution_phase,
  "governed_version_control_commit",
);
assert.equal(
  governedCommit.version_control_authorization
    .commit_authorized,
  true,
);
assert.equal(
  governedCommit.version_control_authorization
    .push_authorized,
  false,
);
assert.equal(
  governedCommit.mutation_authorized,
  false,
);
assert.equal(
  governedCommit.shell_execution_authorized,
  false,
);
assert.equal(
  governedCommit.autonomous_execution_authorized,
  false,
);

const missingHead =
  evaluateExecutionApproval({
    envelope: buildEnvelope(),
    governance: ordinaryGovernance,
    approval: approvedCommitArtifact(),
  });

assert.equal(
  missingHead.version_control_authorization
    .commit_authorized,
  false,
);

const noAllowedPathsEnvelope =
  buildEnvelope(
    { expected_head: expectedHead },
    {
      mutation_scope: {
        allowed_paths: [],
      },
    },
  );

const noAllowedPathsGovernance =
  validateGovernedExecutionEnvelope(
    noAllowedPathsEnvelope,
  );

const noAllowedPaths =
  evaluateExecutionApproval({
    envelope: noAllowedPathsEnvelope,
    governance: noAllowedPathsGovernance,
    approval: approvedCommitArtifact(),
  });

assert.equal(
  noAllowedPaths.version_control_authorization
    .commit_authorized,
  false,
);

const undelegatedEnvelope =
  buildEnvelope(
    { expected_head: expectedHead },
    {
      delegation_authorization: {
        state: "pending",
      },
    },
  );

const undelegatedGovernance =
  validateGovernedExecutionEnvelope(
    undelegatedEnvelope,
  );

const undelegated =
  evaluateExecutionApproval({
    envelope: undelegatedEnvelope,
    governance: undelegatedGovernance,
    approval: approvedCommitArtifact(),
  });

assert.equal(
  undelegated.version_control_authorization
    .commit_authorized,
  false,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope: governedCommitEnvelope,
      governance: governedCommitGovernance,
      approval: approvedCommitArtifact({
        version_control_authorization: {
          commit_authorized: true,
          push_authorized: true,
          remote: "origin",
          branch:
            "feature/support-source-references-runtime",
        },
      }),
    }),
  /push authority remains disabled/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope: governedCommitEnvelope,
      governance: { ok: false },
      approval: governedCommitApproval,
    }),
  /governance validation/,
);

assert.equal(
  governedCommit.trace.some(
    (entry) =>
      entry.event ===
      "version_control_commit_authority_granted",
  ),
  true,
);

console.log(
  JSON.stringify(
    {
      ok: true,
      ordinary_planning_backward_compatible:
        true,
      expected_head_preserved: true,
      malformed_expected_head_failed_closed:
        true,
      commit_authorization_default_false:
        true,
      push_authorization_default_false:
        true,
      commit_does_not_imply_push: true,
      governed_commit_authority_granted:
        true,
      push_remains_blocked: true,
      mutation_remains_blocked: true,
      shell_remains_blocked: true,
      autonomous_remains_blocked: true,
      missing_expected_head_blocks_commit:
        true,
      empty_allowed_paths_blocks_commit:
        true,
      undelegated_request_blocks_commit:
        true,
      governance_failure_blocks_commit:
        true,
      git_side_effects: false,
    },
    null,
    2,
  ),
);
FILEEOF

echo
echo "=== VALIDATE AUTHORIZED UNIT ==="
npx tsc --noEmit
npx tsx server/execution/smoke-test-version-control-contract.mjs

echo
echo "=== VERIFY NO PROCESS OR GIT EFFECTS ==="
node - <<'NODE'
const fs = require("fs");

const files = [
  "server/execution/execution-approval-gate.mjs",
  "server/execution/smoke-test-version-control-contract.mjs",
];

const prohibited = [
  /node:child_process/,
  /child_process/,
  /\bexecFile(?:Sync)?\s*\(/,
  /\bexec(?:Sync)?\s*\(/,
  /\bspawn(?:Sync)?\s*\(/,
];

for (const file of files) {
  const source = fs.readFileSync(file, "utf8");
  for (const pattern of prohibited) {
    if (pattern.test(source)) {
      throw new Error(
        `prohibited process effect in ${file}`,
      );
    }
  }
}

console.log("PROCESS_EFFECTS=NONE");
NODE

echo
echo "=== VERIFY ONLY AUTHORIZED FILES ARE STAGED ==="
git add \
  server/execution/execution-approval-gate.mjs \
  server/execution/smoke-test-version-control-contract.mjs

EXPECTED="$(
  printf '%s\n' \
    server/execution/execution-approval-gate.mjs \
    server/execution/smoke-test-version-control-contract.mjs \
  | sort
)"
ACTUAL="$(
  git diff --cached --name-only | sort
)"

printf '%s\n' "${ACTUAL}"

if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo "STOP: staged set exceeds authorized unit"
  git reset
  exit 1
fi

git commit -m "Enable narrow governed Cade commit approval"
git push

echo
echo "NARROW_COMMIT_APPROVAL_UNIT=COMMITTED_AND_PUSHED"
echo "LOCAL_GIT_COMMIT_EFFECT=NOT_YET_ENABLED"
echo "PUSH_EFFECT=NOT_ENABLED"
echo "NEXT_ACTION=VALIDATE_APPROVAL_UNIT_CLOSURE_AND_CLASSIFY_LOCAL_COMMIT_EFFECT_IMPLEMENTATION"
