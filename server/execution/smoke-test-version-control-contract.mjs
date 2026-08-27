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
