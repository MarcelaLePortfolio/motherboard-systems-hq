#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD_PREFIX="5b5e76948"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo "=== APPLY CADE VERSION CONTROL CONTRACT-ONLY UNIT — ATTEMPT 2 ==="
echo "MODE=EXECUTION"
echo "METHOD=STRUCTURAL_LINE_TRANSFORM_FROM_VERIFIED_CURRENT_SHAPES"
echo "PREVIOUS_FAILED_METHOD=EXACT_WHITESPACE_ANCHOR_REPLACEMENT"
echo "GIT_SIDE_EFFECTS_IN_RUNTIME=PROHIBITED"
echo "CADE_EXECUTOR_CHANGE=PROHIBITED"

python3 << 'PY'
from pathlib import Path

def insert_after_unique_line(path, predicate, new_lines, already_present):
    p = Path(path)
    lines = p.read_text().splitlines(keepends=True)

    if any(already_present(line) for line in lines):
        return

    matches = [i for i, line in enumerate(lines) if predicate(line)]
    if len(matches) != 1:
        raise SystemExit(
            f"{path}: expected exactly one structural anchor, found {len(matches)}"
        )

    i = matches[0]
    indent = lines[i][: len(lines[i]) - len(lines[i].lstrip())]
    rendered = [indent + text + "\n" for text in new_lines]
    lines[i + 1:i + 1] = rendered
    p.write_text("".join(lines))

insert_after_unique_line(
    "server/contracts/execution-envelope.v1.mjs",
    lambda line: 'branch: input?.project_target?.branch ?? "",' in line,
    ['expected_head: input?.project_target?.expected_head ?? null,'],
    lambda line: "expected_head:" in line,
)

insert_after_unique_line(
    "server/execution/build-execution-envelope-draft.mjs",
    lambda line: "branch: project_target.branch ?? null," in line,
    ["expected_head: project_target.expected_head ?? null,"],
    lambda line: "expected_head:" in line,
)

p = Path("server/guards/validate-execution-envelope.mjs")
lines = p.read_text().splitlines(keepends=True)

if not any("project_target.expected_head" in line for line in lines):
    anchor = None
    for i, line in enumerate(lines):
        if '"invalid workspace_type",' in line:
            for j in range(i + 1, min(i + 12, len(lines))):
                if lines[j].strip() == ");":
                    anchor = j
                    break
            break

    if anchor is None:
        raise SystemExit(
            "validate-execution-envelope.mjs: workspace validation boundary not found"
        )

    block = '''
  const expectedHead = envelope?.project_target?.expected_head;

  invariant(
    expectedHead === undefined ||
      expectedHead === null ||
      (
        typeof expectedHead === "string" &&
        /^[0-9a-f]{40}$/i.test(expectedHead)
      ),
    "project_target.expected_head must be a 40-character git commit SHA when supplied",
  );
'''
    lines[anchor + 1:anchor + 1] = [block]
    p.write_text("".join(lines))
PY

cat > server/execution/build-approval-artifact.mjs << 'APPROVALEOF'
export function buildApprovalArtifact({
  requested_by = "Matilda",
  approval_scope = "planning_only",
  justification = "Governed planning validation",
  version_control_authorization = {},
} = {}) {
  return {
    approval_id: `approval-${Date.now()}`,
    approved_by: null,
    approval_scope,
    mutation_authorized: false,
    shell_execution_authorized: false,
    autonomous_execution_authorized: false,
    version_control_authorization: {
      commit_authorized:
        version_control_authorization?.commit_authorized === true,
      push_authorized:
        version_control_authorization?.push_authorized === true,
      remote:
        typeof version_control_authorization?.remote === "string" &&
        version_control_authorization.remote.length > 0
          ? version_control_authorization.remote
          : "origin",
      branch:
        typeof version_control_authorization?.branch === "string" &&
        version_control_authorization.branch.length > 0
          ? version_control_authorization.branch
          : null,
    },
    issued_at: new Date().toISOString(),
    expires_at: null,
    justification,
    requested_by,
    status: "approval_required",
  };
}
APPROVALEOF

cat > server/execution/execution-approval-gate.mjs << 'GATEEOF'
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
  };
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

  return {
    ok: true,
    approval_gate: "canonical_execution_approval_gate",
    execution_phase: "governed_planning_only",
    delegated: envelope?.delegation_authorization?.state === "delegated",
    approval_present: normalized.approval_id !== null,
    mutation_authorized: false,
    shell_execution_authorized: false,
    autonomous_execution_authorized: false,
    version_control_authorization: {
      ...normalized.version_control_authorization,
      commit_authorized: false,
      push_authorized: false,
    },
    approval_artifact: normalized,
    trace: [
      {
        event: "approval_artifact_normalized",
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
      {
        event: "version_control_authority_blocked",
        ok: true,
      },
    ],
  };
}
GATEEOF

cat > server/execution/smoke-test-version-control-contract.mjs << 'TESTEOF'
import assert from "node:assert/strict";

import { createExecutionEnvelope } from "../contracts/execution-envelope.v1.mjs";
import { validateExecutionEnvelope } from "../guards/validate-execution-envelope.mjs";
import { buildApprovalArtifact } from "./build-approval-artifact.mjs";
import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";
import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

function buildEnvelope(projectTarget = {}) {
  return createExecutionEnvelope({
    identity: {
      envelope_id: "env-version-control-contract-smoke",
      intent_id: "intent-version-control-contract-smoke",
    },
    intent: {
      raw_user_intent: "Validate version-control contract semantics only",
      normalized_intent: "Validate contract semantics",
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
    },
    execution_plan: {
      summary: "Validate version-control contract semantics",
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
      success_criteria: ["Contract validation succeeds"],
      failure_conditions: [],
    },
    rollback_contract: {
      rollback_supported: true,
      rollback_method: "git",
      rollback_trigger_conditions: ["validation failure"],
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
    },
  });
}

const ordinary = buildEnvelope();
assert.equal(ordinary.project_target.expected_head, null);
assert.doesNotThrow(() => validateExecutionEnvelope(ordinary));

const expectedHead = "a".repeat(40);
const withExpectedHead = buildEnvelope({
  expected_head: expectedHead,
});
assert.equal(withExpectedHead.project_target.expected_head, expectedHead);
assert.doesNotThrow(() => validateExecutionEnvelope(withExpectedHead));

const malformedExpectedHead = buildEnvelope({
  expected_head: "not-a-git-sha",
});
assert.throws(
  () => validateExecutionEnvelope(malformedExpectedHead),
  /expected_head/,
);

const defaults = buildApprovalArtifact();
assert.equal(
  defaults.version_control_authorization.commit_authorized,
  false,
);
assert.equal(
  defaults.version_control_authorization.push_authorized,
  false,
);
assert.equal(defaults.version_control_authorization.remote, "origin");
assert.equal(defaults.version_control_authorization.branch, null);

const commitOnly = buildApprovalArtifact({
  version_control_authorization: {
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch: "feature/support-source-references-runtime",
  },
});

assert.equal(
  commitOnly.version_control_authorization.commit_authorized,
  true,
);
assert.equal(
  commitOnly.version_control_authorization.push_authorized,
  false,
);
assert.equal(commitOnly.mutation_authorized, false);
assert.equal(commitOnly.shell_execution_authorized, false);

const governance = validateGovernedExecutionEnvelope(ordinary);

const gated = evaluateExecutionApproval({
  envelope: ordinary,
  governance,
  approval: commitOnly,
});

assert.equal(gated.execution_phase, "governed_planning_only");
assert.equal(gated.mutation_authorized, false);
assert.equal(gated.shell_execution_authorized, false);
assert.equal(gated.autonomous_execution_authorized, false);
assert.equal(
  gated.version_control_authorization.commit_authorized,
  false,
);
assert.equal(
  gated.version_control_authorization.push_authorized,
  false,
);

console.log(JSON.stringify({
  ok: true,
  ordinary_planning_backward_compatible: true,
  expected_head_preserved: true,
  malformed_expected_head_failed_closed: true,
  commit_authorization_default_false: true,
  push_authorization_default_false: true,
  commit_does_not_imply_push: true,
  version_control_does_not_enable_mutation: true,
  version_control_does_not_enable_shell: true,
  planning_only_preserved: true,
  git_side_effects: false,
}, null, 2));
TESTEOF

echo "=== RUN REQUIRED VALIDATION ==="
node server/execution/smoke-test-envelope-draft.mjs
node server/execution/smoke-test-approval-gate.mjs
node server/execution/smoke-test-governed-planning-pipeline.mjs
node server/execution/smoke-test-version-control-contract.mjs
npx tsc --noEmit

echo "=== VERIFY AUTHORITY BOUNDARY ==="
git diff --exit-code -- server/cade/cade-executor.ts
git diff --exit-code -- scripts/agents_full/cade.ts

if git diff -U0 | grep -E '^\+.*(execFile|execSync|spawn|git add|git commit|git push)'; then
  echo "STOP: runtime Git/process execution introduced"
  exit 1
fi

echo "CONTRACT_ONLY_UNIT_VALIDATED=YES"
echo "VERSION_CONTROL_EXECUTION_ENABLED=NO"
echo "RUNTIME_GIT_SIDE_EFFECTS=NONE"

git add \
  server/contracts/execution-envelope.v1.mjs \
  server/execution/build-execution-envelope-draft.mjs \
  server/execution/build-approval-artifact.mjs \
  server/execution/execution-approval-gate.mjs \
  server/guards/validate-execution-envelope.mjs \
  server/execution/smoke-test-version-control-contract.mjs

git commit -m "Add Cade version control contract semantics"
git push
