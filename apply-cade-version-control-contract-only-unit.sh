#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD_PREFIX="42b9d3fb0"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

cp server/contracts/execution-envelope.v1.mjs /tmp/execution-envelope.v1.mjs.bak
cp server/execution/build-execution-envelope-draft.mjs /tmp/build-execution-envelope-draft.mjs.bak
cp server/execution/build-approval-artifact.mjs /tmp/build-approval-artifact.mjs.bak
cp server/execution/execution-approval-gate.mjs /tmp/execution-approval-gate.mjs.bak
cp server/guards/validate-execution-envelope.mjs /tmp/validate-execution-envelope.mjs.bak

python3 << 'PY'
from pathlib import Path

p = Path("server/contracts/execution-envelope.v1.mjs")
s = p.read_text()
needle = '''      project_target: {
        project_name: input?.project_target?.project_name ?? "",
        repo_url: input?.project_target?.repo_url ?? "",
        repo_path: input?.project_target?.repo_path ?? "",
        branch: input?.project_target?.branch ?? "",
        workspace_type:
'''
replacement = '''      project_target: {
        project_name: input?.project_target?.project_name ?? "",
        repo_url: input?.project_target?.repo_url ?? "",
        repo_path: input?.project_target?.repo_path ?? "",
        branch: input?.project_target?.branch ?? "",
        expected_head: input?.project_target?.expected_head ?? null,
        workspace_type:
'''
if needle not in s:
    raise SystemExit("execution-envelope project_target anchor not found")
p.write_text(s.replace(needle, replacement, 1))

p = Path("server/execution/build-execution-envelope-draft.mjs")
s = p.read_text()
needle = '''      repo_path: project_target.repo_path ?? null,
      branch: project_target.branch ?? null,
      workspace_type:
'''
replacement = '''      repo_path: project_target.repo_path ?? null,
      branch: project_target.branch ?? null,
      expected_head: project_target.expected_head ?? null,
      workspace_type:
'''
if needle not in s:
    raise SystemExit("draft builder project_target anchor not found")
p.write_text(s.replace(needle, replacement, 1))

p = Path("server/execution/build-approval-artifact.mjs")
s = p.read_text()
p.write_text('''export function buildApprovalArtifact({
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
''')

p = Path("server/execution/execution-approval-gate.mjs")
s = p.read_text()
needle = '''      autonomous_execution_authorized:
        approval?.autonomous_execution_authorized === true,
      issued_at: approval?.issued_at ?? null,
'''
replacement = '''      autonomous_execution_authorized:
        approval?.autonomous_execution_authorized === true,
      version_control_authorization: {
        commit_authorized:
          approval?.version_control_authorization?.commit_authorized === true,
        push_authorized:
          approval?.version_control_authorization?.push_authorized === true,
        remote:
          typeof approval?.version_control_authorization?.remote === "string" &&
          approval.version_control_authorization.remote.length > 0
            ? approval.version_control_authorization.remote
            : "origin",
        branch:
          typeof approval?.version_control_authorization?.branch === "string" &&
          approval.version_control_authorization.branch.length > 0
            ? approval.version_control_authorization.branch
            : null,
      },
      issued_at: approval?.issued_at ?? null,
'''
if needle not in s:
    raise SystemExit("approval gate normalization anchor not found")
s = s.replace(needle, replacement, 1)

needle = '''      autonomous_execution_authorized: false,
      approval_artifact: normalized,
'''
replacement = '''      autonomous_execution_authorized: false,
      version_control_authorization: {
        ...normalized.version_control_authorization,
        commit_authorized: false,
        push_authorized: false,
      },
      approval_artifact: normalized,
'''
if needle not in s:
    raise SystemExit("approval gate return anchor not found")
p.write_text(s.replace(needle, replacement, 1))

p = Path("server/guards/validate-execution-envelope.mjs")
s = p.read_text()
needle = '''export function validateExecutionEnvelope(envelope = {}) {
'''
if needle not in s:
    raise SystemExit("validateExecutionEnvelope anchor not found")
replacement = '''export function validateExecutionEnvelope(envelope = {}) {
  const expectedHead = envelope?.project_target?.expected_head;
  if (
    expectedHead !== undefined &&
    expectedHead !== null &&
    (
      typeof expectedHead !== "string" ||
      !/^[0-9a-f]{40}$/i.test(expectedHead)
    )
  ) {
    fail(
      "EXECUTION_ENVELOPE_VALIDATION_FAILED",
      "project_target.expected_head must be a 40-character git commit SHA when supplied",
    );
  }
'''
p.write_text(s.replace(needle, replacement, 1))
PY

cat > server/execution/smoke-test-version-control-contract.mjs << 'TESTEOF'
import assert from "node:assert/strict";
import { createExecutionEnvelope } from "../contracts/execution-envelope.v1.mjs";
import { validateExecutionEnvelope } from "../guards/validate-execution-envelope.mjs";
import { buildApprovalArtifact } from "./build-approval-artifact.mjs";
import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";
import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

function baseEnvelope(projectTarget = {}) {
  return createExecutionEnvelope({
    identity: {
      envelope_id: "env-vc-contract-smoke",
      intent_id: "intent-vc-contract-smoke",
    },
    intent: {
      raw_user_intent: "Validate bounded version-control contract semantics",
      normalized_intent: "Validate contract only",
      intent_type: "engineering",
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
      summary: "Contract-only validation",
      steps: [
        {
          step_id: "step-1",
          action: "inspect",
          target: "docs/contracts/example.md",
          instructions: "No mutation",
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
    sandbox: {
      dry_run_required: true,
      sandbox_mode: "strict",
      allow_external_side_effects: false,
    },
    delegation_authorization: {
      required: true,
      state: "delegated",
      notes: "Contract-only smoke",
    },
  });
}

const ordinary = baseEnvelope();
assert.equal(ordinary.project_target.expected_head, null);
assert.doesNotThrow(() => validateExecutionEnvelope(ordinary));

const expectedHead = "a".repeat(40);
const bounded = baseEnvelope({ expected_head: expectedHead });
assert.equal(bounded.project_target.expected_head, expectedHead);
assert.doesNotThrow(() => validateExecutionEnvelope(bounded));

const malformed = baseEnvelope({ expected_head: "not-a-sha" });
assert.throws(
  () => validateExecutionEnvelope(malformed),
  /expected_head/,
);

const defaults = buildApprovalArtifact();
assert.equal(defaults.version_control_authorization.commit_authorized, false);
assert.equal(defaults.version_control_authorization.push_authorized, false);
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
assert.equal(commitOnly.version_control_authorization.commit_authorized, true);
assert.equal(commitOnly.version_control_authorization.push_authorized, false);
assert.equal(commitOnly.shell_execution_authorized, false);
assert.equal(commitOnly.mutation_authorized, false);

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
assert.equal(gated.version_control_authorization.commit_authorized, false);
assert.equal(gated.version_control_authorization.push_authorized, false);

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
git diff -- server/cade/cade-executor.ts
git diff -- scripts/agents_full/cade.ts
git grep -n -I -E 'git add|git commit|git push|execFile.*git|spawn.*git' -- \
  server/contracts/execution-envelope.v1.mjs \
  server/execution/build-execution-envelope-draft.mjs \
  server/execution/build-approval-artifact.mjs \
  server/execution/execution-approval-gate.mjs \
  server/guards/validate-execution-envelope.mjs \
  server/execution/governance-validator.mjs \
  server/execution/smoke-test-version-control-contract.mjs || true

git add \
  server/contracts/execution-envelope.v1.mjs \
  server/execution/build-execution-envelope-draft.mjs \
  server/execution/build-approval-artifact.mjs \
  server/execution/execution-approval-gate.mjs \
  server/guards/validate-execution-envelope.mjs \
  server/execution/governance-validator.mjs \
  server/execution/smoke-test-version-control-contract.mjs

git commit -m "Add Cade version control contract semantics"
git push
