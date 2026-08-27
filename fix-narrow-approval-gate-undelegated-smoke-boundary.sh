#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FIX NARROW APPROVAL GATE UNDELEGATED SMOKE BOUNDARY ==="
echo "MODE=EXECUTION"
echo "HYPOTHESIS=APPROVAL_GATE_IMPLEMENTATION_REMAINS_VALID"
echo "FAILURE_CLASS=SMOKE_FIXTURE_BOUNDARY_MISMATCH"
echo "APPROVAL_GATE_EDIT=NO"
echo "SMOKE_EDIT=YES"
echo "LOCAL_GIT_COMMIT_EFFECT_AUTHORIZED=NO"
echo "REMOTE_PUSH_EFFECT_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="36ba946ea"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("server/execution/smoke-test-version-control-contract.mjs")
text = path.read_text()

old = '''const undelegatedGovernance =
  validateGovernedExecutionEnvelope(
    undelegatedEnvelope,
  );

const undelegated =
  evaluateExecutionApproval({
    envelope: undelegatedEnvelope,
    governance: undelegatedGovernance,
    approval: approvedCommitArtifact(),
  });
'''

new = '''assert.throws(
  () =>
    validateGovernedExecutionEnvelope(
      undelegatedEnvelope,
    ),
  /execution not delegated/,
);

const undelegated =
  evaluateExecutionApproval({
    envelope: undelegatedEnvelope,
    governance: {
      ok: true,
    },
    approval: approvedCommitArtifact(),
  });
'''

if old not in text:
    raise SystemExit(
        "STOP: expected undelegated smoke block not found"
    )

path.write_text(text.replace(old, new))
PY

echo
echo "=== VALIDATE AUTHORIZED UNIT ==="
npx tsc --noEmit
npx tsx server/execution/smoke-test-version-control-contract.mjs

echo
echo "=== VERIFY APPROVAL GATE EFFECTIVE SEMANTICS ==="
npx tsx -e '
import assert from "node:assert/strict";
import { createExecutionEnvelope } from "./server/contracts/execution-envelope.v1.mjs";
import { buildApprovalArtifact } from "./server/execution/build-approval-artifact.mjs";
import { evaluateExecutionApproval } from "./server/execution/execution-approval-gate.mjs";
import { validateGovernedExecutionEnvelope } from "./server/execution/governance-validator.mjs";

const envelope = createExecutionEnvelope({
  identity: {
    envelope_id: "env-narrow-vc-approval-validation",
    intent_id: "intent-narrow-vc-approval-validation"
  },
  intent: {
    raw_user_intent: "validate governed commit approval",
    normalized_intent: "validate governed commit approval",
    intent_type: "inspect",
    intent_evidence: ["user_authorization"],
    confidence_score: 1
  },
  project_target: {
    project_name: "Motherboard Systems",
    repo_path: process.cwd(),
    branch: "feature/support-source-references-runtime",
    expected_head: "a".repeat(40),
    workspace_type: "motherboard_systems"
  },
  mutation_scope: {
    scope_type: "file",
    allowed_paths: ["docs/contracts/"],
    forbidden_paths: ["secrets/", ".env"],
    scope_constraints: "approval validation only"
  },
  execution_plan: {
    summary: "validate approval only",
    steps: [{
      step_id: "step-1",
      action: "inspect",
      target: "docs/contracts/example.md",
      instructions: "no effect",
      expected_output: "approval result"
    }]
  },
  patch_spec: {
    format: "structured_patch",
    patches: [{
      file: "docs/contracts/example.md",
      operation: "modify",
      content: "planned only"
    }]
  },
  validation_contract: {
    pre_checks: [],
    post_checks: [],
    success_criteria: ["approval gate validation succeeds"],
    failure_conditions: []
  },
  rollback_contract: {
    rollback_supported: true,
    rollback_method: "git",
    rollback_trigger_conditions: ["validation failure"]
  },
  reconciliation: {
    required: true,
    reconciliation_type: "diff_based"
  },
  sandbox: {
    dry_run_required: true,
    sandbox_mode: "strict",
    allow_external_side_effects: false
  },
  execution_mode: {
    mutation_allowed: false,
    shell_execution_allowed: false,
    autonomous_execution_allowed: false
  },
  delegation_authorization: {
    required: true,
    state: "delegated",
    notes: "approval validation only"
  }
});

const governance = validateGovernedExecutionEnvelope(envelope);

const approval = {
  ...buildApprovalArtifact({
    version_control_authorization: {
      commit_authorized: true,
      push_authorized: false,
      remote: "origin",
      branch: "feature/support-source-references-runtime"
    }
  }),
  status: "approved"
};

const result = evaluateExecutionApproval({
  envelope,
  governance,
  approval
});

assert.equal(
  result.execution_phase,
  "governed_version_control_commit"
);
assert.equal(
  result.version_control_authorization.commit_authorized,
  true
);
assert.equal(
  result.version_control_authorization.push_authorized,
  false
);
assert.equal(result.mutation_authorized, false);
assert.equal(result.shell_execution_authorized, false);
assert.equal(result.autonomous_execution_authorized, false);

console.log("NARROW_COMMIT_APPROVAL_GATE=PASS");
'

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
echo "=== STAGE ONLY AUTHORIZED APPROVAL UNIT ==="
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

echo "STAGED_FILES:"
printf '%s\n' "${ACTUAL}"

if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo "STOP: staged set exceeds authorized approval unit"
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
